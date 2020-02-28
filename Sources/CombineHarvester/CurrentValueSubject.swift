/// A subject that wraps a single value and publishes a new element whenever the value changes.
public final class CurrentValueSubject<Output, Failure>: Subject where Failure: Error {
    /// The value wrapped by this subject, published as a new element whenever it changes.
    public final var value: Output {
        didSet {
            self.send(self.value)
        }
    }

    private var subscriptions = [NestedSubscription]()

    /// Creates a current value subject with the given initial value.
    ///
    /// - Parameter value: The initial value to publish.
    public init(_ value: Output) {
        self.value = value
    }

    private class NestedSubscription: Subscription {
        private let subscriber: AnySubscriber<Output, Failure>
        private let currentValueSubject: CurrentValueSubject

        var demand = Subscribers.Demand.none

        init<S: Subscriber>(_ currentValueSubject: CurrentValueSubject, subscriber: S) where Output == S.Input, Failure == S.Failure {
            self.currentValueSubject = currentValueSubject
            self.subscriber = subscriber.eraseToAnySubscriber()
        }

        func request(_ demand: Subscribers.Demand) {
            let noPreviousDemand = self.demand == .none
            self.demand += demand
            if noPreviousDemand {
                self.send(self.currentValueSubject.value)
            }
        }

        func cancel() {
            self.currentValueSubject.subscriptions.removeAll { $0 === self }
        }

        public final func send(_ value: Output) {
            if self.demand > .none {
                self.demand += self.subscriber.receive(value) - 1
            }
        }

        public final func send(completion: Subscribers.Completion<Failure>) {
            self.subscriber.receive(completion: completion)
            self.cancel()
        }
    }

    public final func receive<S: Subscriber>(subscriber: S) where Output == S.Input, Failure == S.Failure {
        let subscription = NestedSubscription(self, subscriber: subscriber)
        self.send(subscription: subscription)
        self.subscriptions.append(subscription)
        subscriber.receive(subscription: subscription)
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
