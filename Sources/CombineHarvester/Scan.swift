
extension Publishers {
    public struct Scan<Upstream, Output>: Publisher where Upstream: Publisher {
        public typealias Failure = Upstream.Failure

        public let upstream: Upstream

        public let initialResult: Output

        public let nextPartialResult: (Output, Upstream.Output) -> Output

        public init(upstream: Upstream, initialResult: Output, nextPartialResult: @escaping (Output, Upstream.Output) -> Output) {
            self.upstream = upstream
            self.initialResult = initialResult
            self.nextPartialResult = nextPartialResult
        }

        public func receive<S: Subscriber>(subscriber: S) where Output == S.Input, Failure == S.Failure {
            var currentValue = self.initialResult
            self.upstream.map { value in
                currentValue = self.nextPartialResult(currentValue, value)
                return currentValue
            }.subscribe(subscriber)
        }
    }

    public struct TryScan<Upstream, Output>: Publisher where Upstream: Publisher {
        public typealias Failure = Error

        public let upstream: Upstream

        public let initialResult: Output

        public let nextPartialResult: (Output, Upstream.Output) throws -> Output

        public init(upstream: Upstream, initialResult: Output, nextPartialResult: @escaping (Output, Upstream.Output) throws -> Output) {
            self.upstream = upstream
            self.initialResult = initialResult
            self.nextPartialResult = nextPartialResult
        }

        public func receive<S: Subscriber>(subscriber: S) where Output == S.Input, S.Failure == Failure {
            var currentValue = self.initialResult
            self.upstream.tryMap { value in
                currentValue = try self.nextPartialResult(currentValue, value)
                return currentValue
            }.subscribe(subscriber)
        }
    }
}

extension Publisher {
    /// Transforms elements from the upstream publisher by providing the current element to a closure along with the last value returned by the closure.
    ///
    ///     let pub = (0...5)
    ///         .publisher()
    ///         .scan(0, { return $0 + $1 })
    ///         .sink(receiveValue: { print ("\($0)", terminator: " ") })
    ///      // Prints "0 1 3 6 10 15 ".
    ///
    ///
    /// - Parameters:
    ///   - initialResult: The previous result returned by the `nextPartialResult` closure.
    ///   - nextPartialResult: A closure that takes as its arguments the previous value returned by the closure and the next element emitted from the upstream publisher.
    /// - Returns: A publisher that transforms elements by applying a closure that receives its previous return value and the next element from the upstream publisher.
    public func scan<T>(_ initialResult: T, _ nextPartialResult: @escaping (T, Self.Output) -> T) -> Publishers.Scan<Self, T> {
        return Publishers.Scan(upstream: self, initialResult: initialResult, nextPartialResult: nextPartialResult)
    }

    /// Transforms elements from the upstream publisher by providing the current element to an error-throwing closure along with the last value returned by the closure.
    ///
    /// If the closure throws an error, the publisher fails with the error.
    /// - Parameters:
    ///   - initialResult: The previous result returned by the `nextPartialResult` closure.
    ///   - nextPartialResult: An error-throwing closure that takes as its arguments the previous value returned by the closure and the next element emitted from the upstream publisher.
    /// - Returns: A publisher that transforms elements by applying a closure that receives its previous return value and the next element from the upstream publisher.
    public func tryScan<T>(_ initialResult: T, _ nextPartialResult: @escaping (T, Self.Output) throws -> T) -> Publishers.TryScan<Self, T> {
        return Publishers.TryScan(upstream: self, initialResult: initialResult, nextPartialResult: nextPartialResult)
    }
}
