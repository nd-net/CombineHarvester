
extension Publishers {
    public enum PrefetchStrategy: Hashable {
        case keepFull
        
        case byRequest
        
    }
    
    public enum BufferingStrategy<Failure> where Failure: Error {
        case dropNewest
        
        case dropOldest
        
        case customError(() -> Failure)
    }
    
    public struct Buffer<Upstream>: Publisher where Upstream: Publisher {
        /// The kind of values published by this publisher.
        public typealias Output = Upstream.Output
        
        /// The kind of errors this publisher might publish.
        ///
        /// Use `Never` if this `Publisher` does not publish errors.
        public typealias Failure = Upstream.Failure
        
        public let upstream: Upstream
        
        public let size: Int
        
        public let prefetch: Publishers.PrefetchStrategy
        
        public let whenFull: Publishers.BufferingStrategy<Upstream.Failure>
        
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
    public func buffer(size: Int, prefetch: Publishers.PrefetchStrategy, whenFull: Publishers.BufferingStrategy<Self.Failure>) -> Publishers.Buffer<Self> {
        return Publishers.Buffer(upstream: self, size: size, prefetch: prefetch, whenFull: whenFull)
    }
}
