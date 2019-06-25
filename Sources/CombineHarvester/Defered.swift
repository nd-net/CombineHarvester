

extension Publishers {
    /// A publisher that awaits subscription before running the supplied closure to create a publisher for the new subscriber.
    public struct Deferred<DeferredPublisher>: Publisher where DeferredPublisher: Publisher {
        public typealias Output = DeferredPublisher.Output
        public typealias Failure = DeferredPublisher.Failure

        /// The closure to execute when it receives a subscription.
        ///
        /// The publisher returned by this closure immediately receives the incoming subscription.
        public let createPublisher: () -> DeferredPublisher

        /// Creates a deferred publisher.
        ///
        /// - Parameter createPublisher: The closure to execute when calling `subscribe(_:)`.
        public init(createPublisher: @escaping () -> DeferredPublisher) {
            self.createPublisher = createPublisher
        }

        /// This function is called to attach the specified `Subscriber` to this `Publisher` by `subscribe(_:)`
        ///
        /// - SeeAlso: `subscribe(_:)`
        /// - Parameters:
        ///     - subscriber: The subscriber to attach to this `Publisher`.
        ///                   once attached it can begin to receive values.
        public func receive<S>(subscriber: S) where S: Subscriber, DeferredPublisher.Failure == S.Failure, DeferredPublisher.Output == S.Input {
            self.createPublisher().subscribe(subscriber)
        }
    }
}
