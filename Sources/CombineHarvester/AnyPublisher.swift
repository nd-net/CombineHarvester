/// A type-erasing publisher.
///
/// Use `AnyPublisher` to wrap a publisher whose type has details you don’t want to expose to subscribers or other publishers.
public struct AnyPublisher<Output, Failure: Error> { /* : CustomStringConvertible, CustomPlaygroundDisplayConvertible */
    fileprivate let subscribe: (AnySubscriber<Output, Failure>) -> Void

    /// Creates a type-erasing publisher to wrap the provided publisher.
    ///
    /// - Parameters:
    ///   - publisher: A publisher to wrap with a type-eraser.
    public init<P: Publisher>(_ publisher: P) where Output == P.Output, Failure == P.Failure {
        self.subscribe = publisher.subscribe
    }
}

extension AnyPublisher: Publisher {
    public func receive<S: Subscriber>(subscriber: S) where Output == S.Input, Failure == S.Failure {
        self.subscribe(subscriber.eraseToAnySubscriber())
    }
}

extension Publisher {
    /// Wraps this publisher with a type eraser.
    ///
    /// Use `eraseToAnyPublisher()` to expose an instance of AnyPublisher to the downstream subscriber, rather than this publisher’s actual type.
    public func eraseToAnyPublisher() -> AnyPublisher<Self.Output, Self.Failure> {
        return self as? AnyPublisher<Self.Output, Self.Failure> ?? AnyPublisher(self)
    }
}
