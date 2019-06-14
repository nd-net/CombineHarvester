extension Publishers {
    public final class Multicast<Upstream, SubjectType>: ConnectablePublisher where Upstream: Publisher, SubjectType: Subject, Upstream.Failure == SubjectType.Failure, Upstream.Output == SubjectType.Output {
        /// The kind of values published by this publisher.
        public typealias Output = Upstream.Output

        /// The kind of errors this publisher might publish.
        ///
        /// Use `Never` if this `Publisher` does not publish errors.
        public typealias Failure = Upstream.Failure
        
        fileprivate let upstream: Upstream
        fileprivate let createSubject: () -> SubjectType
        
        fileprivate init(upstream: Upstream,createSubject: @escaping () -> SubjectType) {
            self.upstream=upstream
            self.createSubject=createSubject
        }

        /// This function is called to attach the specified `Subscriber` to this `Publisher` by `subscribe(_:)`
        ///
        /// - SeeAlso: `subscribe(_:)`
        /// - Parameters:
        ///     - subscriber: The subscriber to attach to this `Publisher`.
        ///                   once attached it can begin to receive values.
        public final func receive<S>(subscriber: S) where S: Subscriber, SubjectType.Failure == S.Failure, SubjectType.Output == S.Input { notImplemented() }

        /// Connects to the publisher and returns a `Cancellable` instance with which to cancel publishing.
        ///
        /// - Returns: A `Cancellable` instance that can be used to cancel publishing.
        public final func connect() -> Cancellable { notImplemented() }
    }
}

extension Publisher {
    public func multicast<S>(_ createSubject: @escaping () -> S) -> Publishers.Multicast<Self, S> where S: Subject, Self.Failure == S.Failure, Self.Output == S.Output {
        return Publishers.Multicast(upstream: self, createSubject: createSubject)
    }
    
    public func multicast<S>(subject: S) -> Publishers.Multicast<Self, S> where S: Subject, Self.Failure == S.Failure, Self.Output == S.Output {
        return Publishers.Multicast(upstream: self, createSubject: {subject})
    }
}
