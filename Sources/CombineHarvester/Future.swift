/// A publisher that eventually produces one value and then finishes or fails.
public final class Future<Output, Failure>: Publisher where Failure: Error {
    public typealias Promise = (Result<Output, Failure>) -> Void
    private typealias PromiseHandler = (@escaping Promise) -> Void

    private let attemptToFulfill: PromiseHandler

    public init(_ attemptToFulfill: @escaping (@escaping Promise) -> Void) {
        self.attemptToFulfill = attemptToFulfill
    }

    private class FutureSubscription: Subscription {
        private let attemptToFulfill: PromiseHandler
        var subscriber: Atomic<AnySubscriber<Output, Failure>?>

        init<S: Subscriber>(attemptToFulfill: @escaping PromiseHandler, subscriber: S) where Output == S.Input, Failure == S.Failure {
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

    public final func receive<S: Subscriber>(subscriber: S) where Output == S.Input, Failure == S.Failure {
        subscriber.receive(subscription: FutureSubscription(attemptToFulfill: self.attemptToFulfill, subscriber: subscriber))
    }
}
