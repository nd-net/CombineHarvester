
extension Publishers {
    /// A publisher that eventually produces one value and then finishes or fails.
    public final class Future<Output, Failure>: Publisher where Failure: Error {
        private typealias AttemptToFulfill = (@escaping (Result<Output, Failure>) -> Void) -> Void

        private let attemptToFulfill: AttemptToFulfill

        public init(_ attemptToFulfill: @escaping (@escaping (Result<Output, Failure>) -> Void) -> Void) {
            self.attemptToFulfill = attemptToFulfill
        }

        private class FutureSubscription: Subscription {
            private let attemptToFulfill: AttemptToFulfill
            var subscriber: Atomic<AnySubscriber<Output, Failure>?>

            init<S>(attemptToFulfill: @escaping AttemptToFulfill, subscriber: S) where Output == S.Input, Failure == S.Failure, S: Subscriber {
                self.attemptToFulfill = attemptToFulfill
                self.subscriber = Atomic(value: subscriber.eraseToAnySubscriber())
            }

            func request(_ demand: Subscribers.Demand) {
                guard demand > .none, self.subscriber.value != nil else {
                    return
                }
                self.attemptToFulfill { result in
                    guard let subscriber = self.subscriber.swap(nil) else {
                        return
                    }
                    switch result {
                    case let .success(value):
                        _ = subscriber.receive(value)
                        subscriber.receive(completion: .finished)
                    case let .failure(error):
                        subscriber.receive(completion: .failure(error))
                    }
                }
            }

            func cancel() {
                self.subscriber.value = nil
            }
        }

        public final func receive<S>(subscriber: S) where Output == S.Input, Failure == S.Failure, S: Subscriber {
            subscriber.receive(subscription: FutureSubscription(attemptToFulfill: self.attemptToFulfill, subscriber: subscriber))
        }
    }
}
