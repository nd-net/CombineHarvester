
extension Publishers {
    /// A publisher that publishes the number of elements received from the upstream publisher.
    public struct Count<Upstream>: Publisher where Upstream: Publisher {
        public typealias Output = Int
        public typealias Failure = Upstream.Failure

        /// The publisher from which this publisher receives elements.
        public let upstream: Upstream

        public func receive<S>(subscriber: S) where S: Subscriber, Failure == S.Failure, S.Input == Output {
            return self.upstream.reduce(0) { counter, _ in counter + 1 }
                .last()
                .replaceEmpty(with: 0)
                .subscribe(subscriber)
        }
    }
}

extension Publishers.Count: Equatable where Upstream: Equatable {
}

extension Publisher {
    /// Publishes the number of elements received from the upstream publisher.
    ///
    /// - Returns: A publisher that consumes all elements until the upstream publisher finishes, then emits a single
    /// value with the total number of elements received.
    public func count() -> Publishers.Count<Self> {
        return Publishers.Count(upstream: self)
    }
}
