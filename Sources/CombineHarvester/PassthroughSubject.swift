/// A subject that passes along values and completion.
///
/// Use a `PassthroughSubject` in unit tests when you want a publisher than can publish specific values on-demand during tests.
public final class PassthroughSubject<Output, Failure>: Subject where Failure: Error {
    private var subscriptions = [PassthroughSubscription]()

    private class PassthroughSubscription: Subscription {
        var subscriber: Atomic<AnySubscriber<Output, Failure>?>
        var demand = Subscribers.Demand.none

        init<S: Subscriber>(subscriber: S) where Output == S.Input, Failure == S.Failure {
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

    public final func receive<S: Subscriber>(subscriber: S) where Output == S.Input, Failure == S.Failure {
        let subscription = PassthroughSubscription(subscriber: subscriber)
        self.subscriptions.append(subscription)
        self.send(subscription: subscription)
        subscription.sendSubscription()
    }

    public final func send(subscription _: Subscription) {
    }

    public final func send(_ value: Output) {
        for subscription in self.subscriptions {
            subscription.send(value)
        }
    }

    public final func send(completion: Subscribers.Completion<Failure>) {
        for subscription in self.subscriptions {
            subscription.send(completion: completion)
        }
    }
}
