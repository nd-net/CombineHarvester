

extension Publishers {
    /// A publisher that automatically connects and disconnects from this connectable publisher.
    public class Autoconnect<Upstream>: Publisher where Upstream: ConnectablePublisher {
        /// The kind of values published by this publisher.
        public typealias Output = Upstream.Output
        
        /// The kind of errors this publisher might publish.
        ///
        /// Use `Never` if this `Publisher` does not publish errors.
        public typealias Failure = Upstream.Failure
        
        /// The publisher from which this publisher receives elements.
        public final let upstream: Upstream
        
        public init(_ upstream: Upstream) {
            self.upstream=upstream }
        
        /// This function is called to attach the specified `Subscriber` to this `Publisher` by `subscribe(_:)`
        ///
        /// - SeeAlso: `subscribe(_:)`
        /// - Parameters:
        ///     - subscriber: The subscriber to attach to this `Publisher`.
        ///                   once attached it can begin to receive values.
        public func receive<S>(subscriber: S) where S: Subscriber, Upstream.Failure == S.Failure, Upstream.Output == S.Input { notImplemented() }
    }
}



/// A publisher that provides an explicit means of connecting and canceling publication.
///
/// Use `makeConnectable()` to create a `ConnectablePublisher` from any publisher whose failure type is `Never`.
public protocol ConnectablePublisher: Publisher {
    /// Connects to the publisher and returns a `Cancellable` instance with which to cancel publishing.
    ///
    /// - Returns: A `Cancellable` instance that can be used to cancel publishing.
    func connect() -> Cancellable
}

extension ConnectablePublisher {
    /// Automates the process of connecting or disconnecting from this connectable publisher.
    ///
    /// Use `autoconnect()` to simplify working with `ConnectablePublisher` instances, such as those created with `makeConnectable()`.
    ///
    ///     let autoconnectedPublisher = somePublisher
    ///         .makeConnectable()
    ///         .autoconnect()
    ///         .subscribe(someSubscriber)
    ///
    /// - Returns: A publisher which automatically connects to its upstream connectable publisher.
    public func autoconnect() -> Publishers.Autoconnect<Self> {
    return self as? Publishers.Autoconnect<Self> ?? Publishers.Autoconnect(self)
    }
}

