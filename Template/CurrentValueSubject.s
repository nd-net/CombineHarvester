

/// A subject that wraps a single value and publishes a new element whenever the value changes.

public final class CurrentValueSubject<Output, Failure>: Subject where Failure: Error {
    /// The value wrapped by this subject, published as a new element whenever it changes.
    public final var value: Output

    /// Creates a current value subject with the given initial value.
    ///
    /// - Parameter value: The initial value to publish.
    public init(_: Output) { notImplemented() }

    /// This function is called to attach the specified `Subscriber` to this `Publisher` by `subscribe(_:)`
    ///
    /// - SeeAlso: `subscribe(_:)`
    /// - Parameters:
    ///     - subscriber: The subscriber to attach to this `Publisher`.
    ///                   once attached it can begin to receive values.
    public final func receive<S>(subscriber _: S) where Output == S.Input, Failure == S.Failure, S: Subscriber { notImplemented() }

    /// Sends a value to the subscriber.
    ///
    /// - Parameter value: The value to send.
    public final func send(_: Output) { notImplemented() }

    /// Sends a completion signal to the subscriber.
    ///
    /// - Parameter completion: A `Completion` instance which indicates whether publishing has finished normally or failed with an error.
    public final func send(completion _: Subscribers.Completion<Failure>) { notImplemented() }
}
