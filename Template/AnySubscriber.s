// swiftformat:disable redundantGet redundantInit redundantLet redundantLetError redundantPattern unusedArguments

/// A type-erasing subscriber.
///
/// Use an `AnySubscriber` to wrap an existing subscriber whose details you don’t want to expose.
/// You can also use `AnySubscriber` to create a custom subscriber by providing closures for `Subscriber`’s methods, rather than implementing `Subscriber` directly.
public struct AnySubscriber<Input, Failure>: Subscriber, CustomStringConvertible where Failure: Error {
    
    private let receiveSubscription: ((Subscription) -> Void)?
    private let receiveValue: ((Input) -> Subscribers.Demand)?
    private let receiveCompletion: ((Subscribers.Completion<Failure>) -> Void)?
    
    public let combineIdentifier: CombineIdentifier

    public var description: String {
        return combineIdentifier.description }


    /// Creates a type-erasing subscriber to wrap an existing subscriber.
    ///
    /// - Parameter s: The subscriber to type-erase.
    public init<S>(_ s: S) where Input == S.Input, Failure == S.Failure, S: Subscriber {
        self.init(receiveSubscription: s.receive(subscription:),
                  receiveValue: s.receive,
                  receiveCompletion: s.receive(completion: ))
    }

    public init<S>(_ s: S) where Input == S.Output, Failure == S.Failure, S: Subject {
        self.init(receiveSubscription:nil,
                  receiveValue: {
            s.send($0)
            return .unlimited
        },
                  receiveCompletion: s.send(completion: ))
    }

    /// Creates a type-erasing subscriber that executes the provided closures.
    ///
    /// - Parameters:
    ///   - receiveSubscription: A closure to execute when the subscriber receives the initial subscription from the publisher.
    ///   - receiveValue: A closure to execute when the subscriber receives a value from the publisher.
    ///   - receiveCompletion: A closure to execute when the subscriber receives a completion callback from the publisher.
    public init(receiveSubscription: ((Subscription) -> Void)? = nil, receiveValue: ((Input) -> Subscribers.Demand)? = nil, receiveCompletion: ((Subscribers.Completion<Failure>) -> Void)? = nil) {
        self.receiveSubscription=receiveSubscription
        self.receiveValue=receiveValue
        self.receiveCompletion=receiveCompletion
        self.combineIdentifier = CombineIdentifier()
    }

    /// Tells the subscriber that it has successfully subscribed to the publisher and may request items.
    ///
    /// Use the received `Subscription` to request items from the publisher.
    /// - Parameter subscription: A subscription that represents the connection between publisher and subscriber.
    public func receive(subscription: Subscription) {
        self.receiveSubscription?(subscription)}

    /// Tells the subscriber that the publisher has produced an element.
    ///
    /// - Parameter input: The published element.
    /// - Returns: A `Demand` instance indicating how many more elements the subcriber expects to receive.
    public func receive(_ value: Input) -> Subscribers.Demand {
        return self.receiveValue?(value) ?? .none}

    /// Tells the subscriber that the publisher has completed publishing, either normally or with an error.
    ///
    /// - Parameter completion: A `Completion` case indicating whether publishing completed normally or with an error.
    public func receive(completion: Subscribers.Completion<Failure>) {
        self.receiveCompletion?(completion)}
}

extension Subscriber {
    public func eraseToAnySubscriber() -> AnySubscriber<Self.Input, Self.Failure> {
        return self as? AnySubscriber<Self.Input, Self.Failure> ?? AnySubscriber(self)
    }
}
