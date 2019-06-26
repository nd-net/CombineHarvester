/// A subject that passes along values and completion.
///
/// Use a `PassthroughSubject` in unit tests when you want a publisher than can publish specific values on-demand during tests.
public final class PassthroughSubject<Output, Failure>: Subject where Failure: Error {
    private var subscription: PassthroughSubscription? {
        willSet {
            if self.subscription?.combineIdentifier != newValue?.combineIdentifier {
                self.subscription?.cancel()
            }
        }
    }

    private class PassthroughSubscription: Subscription {
        var subscriber: Atomic<AnySubscriber<Output, Failure>?>
        var demand = Subscribers.Demand.none

        init<S>(subscriber: S) where Output == S.Input, Failure == S.Failure, S: Subscriber {
            self.subscriber = Atomic(value: subscriber.eraseToAnySubscriber())
        }

        func request(_ demand: Subscribers.Demand) {
            self.demand += demand
        }

        func cancel() {
            self.subscriber.value = nil
        }

        func sendSubscription() {
            self.subscriber.value?.receive(subscription: self)
        }

        func send(_ value: Output) {
            guard let subscriber = self.subscriber.value else {
                return
            }
            self.demand += subscriber.receive(value)
        }

        func send(completion: Subscribers.Completion<Failure>) {
            self.subscriber.swap(nil)?.receive(completion: completion)
        }

        deinit {
            self.cancel()
        }
    }

    public final func receive<S>(subscriber: S) where Output == S.Input, Failure == S.Failure, S: Subscriber {
        let subscription = PassthroughSubscription(subscriber: subscriber)
        self.subscription = subscription
        subscription.sendSubscription()
    }

    /// Sends a value to the subscriber.
    ///
    /// - Parameter value: The value to send.
    public final func send(_ input: Output) {
        self.subscription?.send(input)
    }

    /// Sends a completion signal to the subscriber.
    ///
    /// - Parameter completion: A `Completion` instance which indicates whether publishing has finished normally or failed with an error.
    public final func send(completion: Subscribers.Completion<Failure>) {
        self.subscription?.send(completion: completion)
    }
}
