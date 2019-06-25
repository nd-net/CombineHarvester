
extension Publishers {
    /// A publisher that applies a closure to all received elements and produces an accumulated value when the upstream publisher finishes.
    public struct Reduce<Upstream, Output>: Publisher where Upstream: Publisher {
        public typealias Failure = Upstream.Failure
        public let upstream: Upstream

        /// The initial value provided on the first invocation of the closure.
        public let initial: Output

        /// A closure that takes the previously-accumulated value and the next element from the upstream publisher to produce a new value.
        public let nextPartialResult: (Output, Upstream.Output) -> Output

        public func receive<S>(subscriber: S) where Output == S.Input, S: Subscriber, Upstream.Failure == S.Failure {
            self.upstream.scan(self.initial, self.nextPartialResult)
                .last()
                .subscribe(subscriber)
        }
    }

    /// A publisher that applies an error-throwing closure to all received elements and produces an accumulated value when the upstream publisher finishes.
    public struct TryReduce<Upstream, Output>: Publisher where Upstream: Publisher {
        public typealias Failure = Error

        /// The publisher from which this publisher receives elements.
        public let upstream: Upstream

        /// The initial value provided on the first invocation of the closure.
        public let initial: Output

        /// An error-throwing closure that takes the previously-accumulated value and the next element from the upstream to produce a new value.
        ///
        /// If this closure throws an error, the publisher fails and passes the error to its subscriber.
        public let nextPartialResult: (Output, Upstream.Output) throws -> Output

        public func receive<S>(subscriber: S) where Output == S.Input, S: Subscriber, S.Failure == Publishers.TryReduce<Upstream, Output>.Failure {
            self.upstream.tryScan(self.initial, self.nextPartialResult)
                .last()
                .subscribe(subscriber)
        }
    }
}

extension Publisher {
    /// Applies a closure that accumulates each element of a stream and publishes a final result upon completion.
    ///
    /// - Parameters:
    ///   - initialResult: The value the closure receives the first time it is called.
    ///   - nextPartialResult: A closure that takes the previously-accumulated value and the next element from the upstream publisher to produce a new value.
    /// - Returns: A publisher that applies the closure to all received elements and produces an accumulated value when the upstream publisher finishes.
    public func reduce<T>(_ initialResult: T, _ nextPartialResult: @escaping (T, Self.Output) -> T) -> Publishers.Reduce<Self, T> {
        return Publishers.Reduce(upstream: self, initial: initialResult, nextPartialResult: nextPartialResult)
    }

    /// Applies an error-throwing closure that accumulates each element of a stream and publishes a final result upon completion.
    ///
    /// If the closure throws an error, the publisher fails, passing the error to its subscriber.
    /// - Parameters:
    ///   - initialResult: The value the closure receives the first time it is called.
    ///   - nextPartialResult: An error-throwing closure that takes the previously-accumulated value and the next element from the upstream publisher to produce a new value.
    /// - Returns: A publisher that applies the closure to all received elements and produces an accumulated value when the upstream publisher finishes.
    public func tryReduce<T>(_ initialResult: T, _ nextPartialResult: @escaping (T, Self.Output) throws -> T) -> Publishers.TryReduce<Self, T> {
        return Publishers.TryReduce(upstream: self, initial: initialResult, nextPartialResult: nextPartialResult)
    }
}
