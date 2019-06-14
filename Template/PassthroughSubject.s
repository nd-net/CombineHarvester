// swiftformat:disable redundantGet redundantInit redundantLet redundantLetError redundantPattern unusedArguments

/// A subject that passes along values and completion.
///
/// Use a `PassthroughSubject` in unit tests when you want a publisher than can publish specific values on-demand during tests.

public final class PassthroughSubject<Output, Failure>: Subject where Failure: Error {

    /// This function is called to attach the specified `Subscriber` to this `Publisher` by `subscribe(_:)`
    ///
    /// - SeeAlso: `subscribe(_:)`
    /// - Parameters:
    ///     - subscriber: The subscriber to attach to this `Publisher`.
    ///                   once attached it can begin to receive values.
    public final func receive<S>(subscriber: S) where Output == S.Input, Failure == S.Failure, S: Subscriber {
        notImplemented()
    }

    /// Sends a value to the subscriber.
    ///
    /// - Parameter value: The value to send.
    public final func send(_ input: Output) { notImplemented() }

    /// Sends a completion signal to the subscriber.
    ///
    /// - Parameter completion: A `Completion` instance which indicates whether publishing has finished normally or failed with an error.
    public final func send(completion: Subscribers.Completion<Failure>) { notImplemented() }
}
