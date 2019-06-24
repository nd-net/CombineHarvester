
extension Publishers {
    /// A publisher that publishes the number of elements received from the upstream publisher.
    public struct Count<Upstream>: Publisher where Upstream: Publisher {
        public typealias Output = Int
        public typealias Failure = Upstream.Failure

        /// The publisher from which this publisher receives elements.
        public let upstream: Upstream

        private class Counter<Input, Failure: Error>: Subscriber, Subscription {
            private let receiveSubscription: (Subscription) -> Void
            private let receiveValue: (Int) -> Subscribers.Demand
            private let receiveCompletion: (Subscribers.Completion<Failure>) -> Void

            private var count = 0

            private var upstreamSubscription: Subscription?
            private var didRequest = false

            init<S>(subscriber: S) where S: Subscriber, Failure == S.Failure, S.Input == Int {
                self.receiveSubscription = subscriber.receive(subscription:)
                self.receiveValue = subscriber.receive
                self.receiveCompletion = subscriber.receive(completion:)
            }

            func receive(subscription: Subscription) {
                self.upstreamSubscription = subscription
                self.receiveSubscription(subscription)
            }

            func receive(_: Input) -> Subscribers.Demand {
                self.count += 1
                return .unlimited
            }

            func receive(completion: Subscribers.Completion<Failure>) {
                switch completion {
                case .finished:
                    _ = self.receiveValue(self.count)
                    self.receiveCompletion(completion)
                case .failure:
                    self.receiveCompletion(completion)
                }
                self.cancel()
            }

            func request(_ demand: Subscribers.Demand) {
                guard demand > .none, !self.didRequest else {
                    return
                }
                self.didRequest = true
                self.upstreamSubscription?.request(.unlimited)
            }

            func cancel() {
                self.upstreamSubscription?.cancel()
                self.upstreamSubscription = nil
            }

            deinit {
                self.cancel()
            }
        }

        public func receive<S>(subscriber: S) where S: Subscriber, Failure == S.Failure, S.Input == Output {
            self.upstream.subscribe(Counter(subscriber: subscriber))
        }
    }
}

extension Publisher {
    /// Publishes the number of elements received from the upstream publisher.
    ///
    /// - Returns: A publisher that consumes all elements until the upstream publisher finishes, then emits a single
    /// value with the total number of elements received.
    public func count() -> Publishers.Count<Self> {
        return Publishers.Count(upstream: self)
    }
}
