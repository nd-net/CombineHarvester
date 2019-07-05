
extension Publishers {
    /// A publisher that ignores all upstream elements, but passes along a completion state (finish or failed).
    public struct IgnoreOutput<Upstream: Publisher>: Publisher {
        public typealias Output = Never
        public typealias Failure = Upstream.Failure

        /// The publisher from which this publisher receives elements.
        public let upstream: Upstream

        public init(upstream: Upstream) {
            self.upstream = upstream
        }

        public func receive<S: Subscriber>(subscriber: S) where Failure == S.Failure, S.Input == Output {
            self.upstream
                .compactMap { _ in nil }
                .last()
                .subscribe(subscriber)
        }
    }
}

extension Publishers.IgnoreOutput: Equatable where Upstream: Equatable {
}

extension Publisher {
    /// Ingores all upstream elements, but passes along a completion state (finished or failed).
    ///
    /// The output type of this publisher is `Never`.
    /// - Returns: A publisher that ignores all upstream elements.
    public func ignoreOutput() -> Publishers.IgnoreOutput<Self> {
        return Publishers.IgnoreOutput(upstream: self)
    }
}
