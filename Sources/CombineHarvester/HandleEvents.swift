
extension Publishers {
    /// A publisher that performs the specified closures when publisher events occur.
    public struct HandleEvents<Upstream: Publisher>: Publisher {
        public typealias Output = Upstream.Output
        public typealias Failure = Upstream.Failure

        /// The publisher from which this publisher receives elements.
        public let upstream: Upstream

        /// A closure that executes when the publisher receives the subscription from the upstream publisher.
        public var receiveSubscription: ((Subscription) -> Void)?

        ///  A closure that executes when the publisher receives a value from the upstream publisher.
        public var receiveOutput: ((Upstream.Output) -> Void)?

        /// A closure that executes when the publisher receives the completion from the upstream publisher.
        public var receiveCompletion: ((Subscribers.Completion<Upstream.Failure>) -> Void)?

        ///  A closure that executes when the downstream receiver cancels publishing.
        public var receiveCancel: (() -> Void)?

        /// A closure that executes when the publisher receives a request for more elements.
        public var receiveRequest: ((Subscribers.Demand) -> Void)?

        public init(upstream: Upstream, receiveSubscription: ((Subscription) -> Void)? = nil, receiveOutput: ((Publishers.HandleEvents<Upstream>.Output) -> Void)? = nil, receiveCompletion: ((Subscribers.Completion<Publishers.HandleEvents<Upstream>.Failure>) -> Void)? = nil, receiveCancel: (() -> Void)? = nil, receiveRequest: ((Subscribers.Demand) -> Void)?) {
            self.upstream = upstream
            self.receiveSubscription = receiveSubscription
            self.receiveOutput = receiveOutput
            self.receiveCompletion = receiveCompletion
            self.receiveCancel = receiveCancel
            self.receiveRequest = receiveRequest
        }

        private class HandlingSubscription: Subscription {
            private let upstream: Subscription
            private let receiveRequest: ((Subscribers.Demand) -> Void)?
            private let receiveCancel: (() -> Void)?

            init(upstream: Subscription, receiveRequest: ((Subscribers.Demand) -> Void)?, receiveCancel: (() -> Void)?) {
                self.upstream = upstream
                self.receiveRequest = receiveRequest
                self.receiveCancel = receiveCancel
            }

            func request(_ demand: Subscribers.Demand) {
                self.receiveRequest?(demand)
                self.upstream.request(demand)
            }

            func cancel() {
                self.receiveCancel?()
                self.upstream.cancel()
            }

            var combineIdentifier: CombineIdentifier {
                return self.upstream.combineIdentifier
            }
        }

        public func receive<S: Subscriber>(subscriber: S) where Upstream.Failure == S.Failure, Upstream.Output == S.Input {
            guard self.receiveCancel != nil || self.receiveOutput != nil || self.receiveRequest != nil || self.receiveCompletion != nil || self.receiveSubscription != nil else {
                self.upstream.subscribe(subscriber)
                return
            }

            let handlingSubscriber = AnySubscriber<S.Input, S.Failure>(
                receiveSubscription: { subscription in
                    let nestedSubscription = HandlingSubscription(
                        upstream: subscription,
                        receiveRequest: self.receiveRequest,
                        receiveCancel: self.receiveCancel
                    )
                    self.receiveSubscription?(nestedSubscription)
                    subscriber.receive(subscription: nestedSubscription)
                }, receiveValue: { value in
                    self.receiveOutput?(value)
                    return subscriber.receive(value)
                }, receiveCompletion: { completion in
                    self.receiveCompletion?(completion)
                    subscriber.receive(completion: completion)
                }
            )
            upstream.subscribe(handlingSubscriber)
        }
    }
}

extension Publisher {
    /// Performs the specified closures when publisher events occur.
    ///
    /// - Parameters:
    ///   - receiveSubscription: A closure that executes when the publisher receives the  subscription from the upstream publisher. Defaults to `nil`.
    ///   - receiveOutput: A closure that executes when the publisher receives a value from the upstream publisher. Defaults to `nil`.
    ///   - receiveCompletion: A closure that executes when the publisher receives the completion from the upstream publisher. Defaults to `nil`.
    ///   - receiveCancel: A closure that executes when the downstream receiver cancels publishing. Defaults to `nil`.
    ///   - receiveRequest: A closure that executes when the publisher receives a request for more elements. Defaults to `nil`.
    /// - Returns: A publisher that performs the specified closures when publisher events occur.
    public func handleEvents(receiveSubscription: ((Subscription) -> Void)? = nil, receiveOutput: ((Self.Output) -> Void)? = nil, receiveCompletion: ((Subscribers.Completion<Self.Failure>) -> Void)? = nil, receiveCancel: (() -> Void)? = nil, receiveRequest: ((Subscribers.Demand) -> Void)? = nil) -> Publishers.HandleEvents<Self> {
        return Publishers.HandleEvents(upstream: self, receiveSubscription: receiveSubscription, receiveOutput: receiveOutput, receiveCompletion: receiveCompletion, receiveCancel: receiveCancel, receiveRequest: receiveRequest)
    }
}
