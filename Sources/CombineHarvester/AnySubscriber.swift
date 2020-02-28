/// A type-erasing subscriber.
///
/// Use an `AnySubscriber` to wrap an existing subscriber whose details you don’t want to expose.
/// You can also use `AnySubscriber` to create a custom subscriber by providing closures for `Subscriber`’s methods, rather than implementing `Subscriber` directly.
public struct AnySubscriber<Input, Failure: Error>: Subscriber, CustomStringConvertible /* ,CustomReflectable, CustomPlaygroundDisplayConvertible */ {
    fileprivate class SubscriptionBox: Cancellable {
        private var _subscription = Atomic<Subscription?>(value: nil)

        var subscription: Subscription? {
            get {
                return self._subscription.value
            }
            set {
                let old = self._subscription.swap(newValue)
                if old?.combineIdentifier != newValue?.combineIdentifier {
                    old?.cancel()
                }
            }
        }

        func cancel() {
            self.subscription = nil
        }
    }

    private let receiveSubscription: (Subscription) -> Void
    private let receiveValue: (Input) -> Subscribers.Demand
    private let receiveCompletion: (Subscribers.Completion<Failure>) -> Void
    public let combineIdentifier: CombineIdentifier

    fileprivate let subscriptionBox = SubscriptionBox()

    private static func defaultReceive(subscription: Subscription) {
        subscription.request(.unlimited)
    }

    /// Creates a type-erasing subscriber to wrap an existing subscriber.
    ///
    /// - Parameter s: The subscriber to type-erase.
    public init<S: Subscriber>(_ s: S) where Input == S.Input, Failure == S.Failure {
        self.init(receiveSubscription: s.receive(subscription:),
                  receiveValue: s.receive,
                  receiveCompletion: s.receive(completion:),
                  combineIdentifier: s.combineIdentifier)
    }

    public init<S: Subject>(_ s: S) where Input == S.Output, Failure == S.Failure {
        self.init(receiveSubscription: AnySubscriber<Input, Failure>.defaultReceive(subscription:),
                  receiveValue: {
                      s.send($0)
                      return .unlimited
                  },
                  receiveCompletion: s.send(completion:),
                  combineIdentifier: CombineIdentifier(s))
    }

    /// Creates a type-erasing subscriber that executes the provided closures.
    ///
    /// - Parameters:
    ///   - receiveSubscription: A closure to execute when the subscriber receives the initial subscription from the publisher.
    ///   - receiveValue: A closure to execute when the subscriber receives a value from the publisher.
    ///   - receiveCompletion: A closure to execute when the subscriber receives a completion callback from the publisher.
    public init(receiveSubscription: ((Subscription) -> Void)? = nil, receiveValue: ((Input) -> Subscribers.Demand)? = nil, receiveCompletion: ((Subscribers.Completion<Failure>) -> Void)? = nil) {
        self.init(
            receiveSubscription: receiveSubscription ?? AnySubscriber<Input, Failure>.defaultReceive(subscription:),
            // the default implementation of receiveValue demands unlimited data (so that the subscription may complete)
            receiveValue: receiveValue ?? { _ in .unlimited },
            receiveCompletion: receiveCompletion ?? { _ in },
            combineIdentifier: CombineIdentifier()
        )
    }

    private init(receiveSubscription: @escaping ((Subscription) -> Void), receiveValue: @escaping ((Input) -> Subscribers.Demand), receiveCompletion: @escaping ((Subscribers.Completion<Failure>) -> Void), combineIdentifier: CombineIdentifier) {
        self.receiveSubscription = receiveSubscription
        self.receiveValue = receiveValue
        self.receiveCompletion = receiveCompletion
        self.combineIdentifier = combineIdentifier
    }

    public var description: String {
        return self.combineIdentifier.description
    }

    public func receive(subscription: Subscription) {
        self.subscriptionBox.subscription = subscription
        self.receiveSubscription(subscription)
    }

    public func receive(_ value: Input) -> Subscribers.Demand {
        return self.receiveValue(value)
    }

    public func receive(completion: Subscribers.Completion<Failure>) {
        self.receiveCompletion(completion)
    }
}

extension Subscriber {
    internal func eraseToAnySubscriber() -> AnySubscriber<Self.Input, Self.Failure> {
        return self as? AnySubscriber<Self.Input, Self.Failure> ?? AnySubscriber(self)
    }
}

extension Publisher {
    public func subscribe<S: Subject>(_ subject: S) -> AnyCancellable where Self.Failure == S.Failure, Self.Output == S.Output {
        let subscriber = AnySubscriber(subject)
        self.receive(subscriber: subscriber)

        return AnyCancellable(subscriber.subscriptionBox)
    }
}
