public final class AnySubject<Output, Failure>: Subject where Failure: Error {
    private let didSubscribe: (AnySubscriber<Output, Failure>) -> Void
    private let didReceiveValue: (Output) -> Void
    private let didReceiveCompletion: (Subscribers.Completion<Failure>) -> Void

    public init<S>(_ subject: S) where Output == S.Output, Failure == S.Failure, S: Subject {
        self.didSubscribe = subject.subscribe
        self.didReceiveValue = subject.send
        self.didReceiveCompletion = subject.send(completion:)
    }

    public init(_ subscribe: @escaping (AnySubscriber<Output, Failure>) -> Void, _ receive: @escaping (Output) -> Void, _ receiveCompletion: @escaping (Subscribers.Completion<Failure>) -> Void) {
        self.didSubscribe = subscribe
        self.didReceiveValue = receive
        self.didReceiveCompletion = receiveCompletion
    }

    public final func receive<S>(subscriber: S) where Output == S.Input, Failure == S.Failure, S: Subscriber {
        self.didSubscribe(subscriber.eraseToAnySubscriber())
    }

    public final func send(_ value: Output) {
        self.didReceiveValue(value)
    }

    public final func send(completion: Subscribers.Completion<Failure>) {
        self.didReceiveCompletion(completion)
    }
}

extension Subject {
    public func eraseToAnySubject() -> AnySubject<Self.Output, Self.Failure> {
        return self as? AnySubject<Self.Output, Self.Failure> ?? AnySubject(self)
    }
}
