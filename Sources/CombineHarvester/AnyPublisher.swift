/// A type-erasing publisher.
///
/// Use `AnyPublisher` to wrap a publisher whose type has details you don’t want to expose to subscribers or other publishers.
public struct AnyPublisher<Output, Failure> where Failure: Error {
    fileprivate let subscriptionHandler: (AnySubscriber<Output, Failure>) -> Void

    /// Creates a type-erasing publisher to wrap the provided publisher.
    ///
    /// - Parameters:
    ///   - publisher: A publisher to wrap with a type-eraser.
    @inlinable public init<P>(_ publisher: P) where Output == P.Output, Failure == P.Failure, P: Publisher {
        self.init(publisher.subscribe)
    }

    /// Creates a type-erasing publisher implemented by the provided closure.
    ///
    /// - Parameters:
    ///   - subscribe: A closure to invoke when a subscriber subscribes to the publisher.
    public init(_ subscribe: @escaping (AnySubscriber<Output, Failure>) -> Void) {
        self.subscriptionHandler = subscribe
    }
}

extension AnyPublisher: Publisher {
    public func receive<S>(subscriber: S) where Output == S.Input, Failure == S.Failure, S: Subscriber {
        self.subscriptionHandler(subscriber.eraseToAnySubscriber())
    }
}

extension Publisher {
    public func eraseToAnyPublisher() -> AnyPublisher<Self.Output, Self.Failure> {
        return self as? AnyPublisher<Self.Output, Self.Failure> ?? AnyPublisher(self)
    }
}
