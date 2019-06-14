/// A type-erasing subscriber.
///
/// Use an `AnySubscriber` to wrap an existing subscriber whose details you don’t want to expose.
/// You can also use `AnySubscriber` to create a custom subscriber by providing closures for `Subscriber`’s methods, rather than implementing `Subscriber` directly.
public struct AnySubscriber<Input, Failure>: Subscriber, CustomStringConvertible /* ,CustomReflectable, CustomPlaygroundDisplayConvertible */ where Failure: Error {
    private let receiveSubscription: (Subscription) -> Void
    private let receiveValue: (Input) -> Subscribers.Demand
    private let receiveCompletion: (Subscribers.Completion<Failure>) -> Void
    public let combineIdentifier: CombineIdentifier

    /// Creates a type-erasing subscriber to wrap an existing subscriber.
    ///
    /// - Parameter s: The subscriber to type-erase.
    public init<S>(_ s: S) where Input == S.Input, Failure == S.Failure, S: Subscriber {
        self.init(receiveSubscription: s.receive(subscription:),
                  receiveValue: s.receive,
                  receiveCompletion: s.receive(completion:),
                  combineIdentifier: s.combineIdentifier)
    }

    #if false // Subject not yet implemented
        public init<S>(_ s: S) where Input == S.Output, Failure == S.Failure, S: Subject {
            self.init(receiveSubscription: nil,
                      receiveValue: {
                          s.send($0)
                          return .unlimited
                      },
                      receiveCompletion: s.send(completion:),
                      combineIdentifier: CombineIdentifier(s))
        }
    #endif

    /// Creates a type-erasing subscriber that executes the provided closures.
    ///
    /// - Parameters:
    ///   - receiveSubscription: A closure to execute when the subscriber receives the initial subscription from the publisher.
    ///   - receiveValue: A closure to execute when the subscriber receives a value from the publisher.
    ///   - receiveCompletion: A closure to execute when the subscriber receives a completion callback from the publisher.
    public init(receiveSubscription: ((Subscription) -> Void)? = nil, receiveValue: ((Input) -> Subscribers.Demand)? = nil, receiveCompletion: ((Subscribers.Completion<Failure>) -> Void)? = nil) {
        self.init(
            receiveSubscription: receiveSubscription ?? { _ in },
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
    public func eraseToAnySubscriber() -> AnySubscriber<Self.Input, Self.Failure> {
        return self as? AnySubscriber<Self.Input, Self.Failure> ?? AnySubscriber(self)
    }
}
