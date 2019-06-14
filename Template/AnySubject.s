
public final class AnySubject<Output, Failure>: Subject where Failure: Error {
    private let subscribe:  (AnySubscriber<Output, Failure>) -> Void
    private let receive:  (Output) -> Void
    private let receiveCompletion: (Subscribers.Completion<Failure>) -> Void
    
    public init<S>(_ subject: S) where Output == S.Output, Failure == S.Failure, S: Subject {
        self.subscribe = subject.subscribe
        self.receive=subject.send
        self.receiveCompletion = subject.send(completion: )
    }

    public init(_ subscribe: @escaping (AnySubscriber<Output, Failure>) -> Void, _ receive: @escaping (Output) -> Void, _ receiveCompletion: @escaping (Subscribers.Completion<Failure>) -> Void) {
    self.subscribe=subscribe
        self.receive=receive
        self.receiveCompletion=receiveCompletion
    }

    /// This function is called to attach the specified `Subscriber` to this `Publisher` by `subscribe(_:)`
    ///
    /// - SeeAlso: `subscribe(_:)`
    /// - Parameters:
    ///     - subscriber: The subscriber to attach to this `Publisher`.
    ///                   once attached it can begin to receive values.
    public final func receive<S>(subscriber: S) where Output == S.Input, Failure == S.Failure, S: Subscriber {
        self.subscribe(subscriber.eraseToAnySubscriber())
    }

    /// Sends a value to the subscriber.
    ///
    /// - Parameter value: The value to send.
    public final func send(_ value: Output) {
        self.receive(value)
    }

    /// Sends a completion signal to the subscriber.
    ///
    /// - Parameter completion: A `Completion` instance which indicates whether publishing has finished normally or failed with an error.
    public final func send(completion: Subscribers.Completion<Failure>) {
        self.receiveCompletion(completion)
    }
}

extension Subject {
    public func eraseToAnySubject() -> AnySubject<Self.Output, Self.Failure> {
        return self as?  AnySubject<Self.Output, Self.Failure> ?? AnySubject(self)}
}
