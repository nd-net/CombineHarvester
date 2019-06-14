
extension Publishers {
    /// A publisher that only publishes the last element of a stream, after the stream finishes.
    public struct Last<Upstream>: Publisher where Upstream: Publisher {
        /// The kind of values published by this publisher.
        public typealias Output = Upstream.Output
        
        /// The kind of errors this publisher might publish.
        ///
        /// Use `Never` if this `Publisher` does not publish errors.
        public typealias Failure = Upstream.Failure
        
        /// The publisher from which this publisher receives elements.
        public let upstream: Upstream
        
        /// This function is called to attach the specified `Subscriber` to this `Publisher` by `subscribe(_:)`
        ///
        /// - SeeAlso: `subscribe(_:)`
        /// - Parameters:
        ///     - subscriber: The subscriber to attach to this `Publisher`.
        ///                   once attached it can begin to receive values.
        public func receive<S>(subscriber: S) where S: Subscriber, Upstream.Failure == S.Failure, Upstream.Output == S.Input { notImplemented() }
    }
}


extension Publishers.Last: Equatable where Upstream: Equatable {
    /// Returns a Boolean value that indicates whether two publishers are equivalent.
    ///
    /// - Parameters:
    ///   - lhs: A last publisher to compare for equality.
    ///   - rhs: Another last publisher to compare for equality.
    /// - Returns: `true` if the two publishers have equal upstream publishers, `false` otherwise.
    public static func == (lhs: Publishers.Last<Upstream>, rhs: Publishers.Last<Upstream>) -> Bool {
    return lhs.upstream == rhs.upstream
    }
}

extension Publisher {
    /// Only publishes the last element of a stream, after the stream finishes.
    /// - Returns: A publisher that only publishes the last element of a stream.
    public func last() -> Publishers.Last<Self> {
        return Publishers.Last(upstream: self)
    }
}

