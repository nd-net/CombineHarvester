
extension Publishers {
    /// A publisher that receives elements from an upstream publisher on a specific scheduler.
    public struct SubscribeOn<Upstream, Context>: Publisher where Upstream: Publisher, Context: Scheduler {
        /// The kind of values published by this publisher.
        public typealias Output = Upstream.Output
        
        /// The kind of errors this publisher might publish.
        ///
        /// Use `Never` if this `Publisher` does not publish errors.
        public typealias Failure = Upstream.Failure
        
        /// The publisher from which this publisher receives elements.
        public let upstream: Upstream
        
        /// The scheduler the publisher should use to receive elements.
        public let scheduler: Context
        
        /// Scheduler options that customize the delivery of elements.
        public let options: Context.SchedulerOptions?
        
        /// This function is called to attach the specified `Subscriber` to this `Publisher` by `subscribe(_:)`
        ///
        /// - SeeAlso: `subscribe(_:)`
        /// - Parameters:
        ///     - subscriber: The subscriber to attach to this `Publisher`.
        ///                   once attached it can begin to receive values.
        public func receive<S>(subscriber: S) where S: Subscriber, Upstream.Failure == S.Failure, Upstream.Output == S.Input { notImplemented() }
    }
}

extension Publisher {
    /// Specifies the scheduler on which to perform subscribe, cancel, and request operations.
    ///
    /// In contrast with `receive(on:options:)`, which affects downstream messages, `subscribe(on:)` changes the execution context of upstream messages. In the following example, requests to `jsonPublisher` are performed on `backgroundQueue`, but elements received from it are performed on `RunLoop.main`.
    ///
    ///     let ioPerformingPublisher == // Some publisher.
    ///     let uiUpdatingSubscriber == // Some subscriber that updates the UI.
    ///
    ///     ioPerformingPublisher
    ///         .subscribe(on: backgroundQueue)
    ///         .receiveOn(on: RunLoop.main)
    ///         .subscribe(uiUpdatingSubscriber)
    ///
    /// - Parameters:
    ///   - scheduler: The scheduler on which to receive upstream messages.
    ///   - options: Options that customize the delivery of elements.
    /// - Returns: A publisher which performs upstream operations on the specified scheduler.
    public func subscribe<S>(on scheduler: S, options: S.SchedulerOptions? = nil) -> Publishers.SubscribeOn<Self, S> where S: Scheduler {
        return Publishers.SubscribeOn(upstream: self, scheduler: scheduler,options:options)
    }
}
