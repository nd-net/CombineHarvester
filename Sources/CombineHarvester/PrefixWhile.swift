
extension Publishers {
    /// A publisher that republishes elements while a predicate closure indicates publishing should continue.
    public struct PrefixWhile<Upstream: Publisher>: Publisher {
        public typealias Output = Upstream.Output
        public typealias Failure = Upstream.Failure

        /// The publisher from which this publisher receives elements.
        public let upstream: Upstream

        /// The closure that determines whether whether publishing should continue.
        public let predicate: (Upstream.Output) -> Bool

        public init(upstream: Upstream, predicate: @escaping (Output) -> Bool) {
            self.upstream = upstream
            self.predicate = predicate
        }

        public func receive<S: Subscriber>(subscriber: S) where Failure == S.Failure, Output == S.Input {
            self.upstream.subscribe(TransformingSubscriber(
                subscriber: subscriber,
                transformRequest: { [.demand($0)] },
                transformValue: { value in
                    if self.predicate(value) {
                        return [.value(value)]
                    }
                    return [.finished]
                }
            )
            )
        }
    }

    /// A publisher that republishes elements while an error-throwing predicate closure indicates publishing should continue.
    public struct TryPrefixWhile<Upstream: Publisher>: Publisher {
        public typealias Output = Upstream.Output
        public typealias Failure = Error

        /// The publisher from which this publisher receives elements.
        public let upstream: Upstream

        /// The error-throwing closure that determines whether publishing should continue.
        public let predicate: (Output) throws -> Bool

        public init(upstream: Upstream, predicate: @escaping (Output) throws -> Bool) {
            self.upstream = upstream
            self.predicate = predicate
        }

        public func receive<S: Subscriber>(subscriber: S) where Output == S.Input, S.Failure == Failure {
            self.upstream.subscribe(TransformingSubscriber(
                subscriber: subscriber,
                transformRequest: { [.demand($0)] },
                transformValue: { value in
                    do {
                        if try self.predicate(value) {
                            return [.value(value)]
                        }
                        return [.finished]
                    } catch {
                        return [.failure(error)]
                    }
                }
            )
            )
        }
    }
}

extension Publisher {
    /// Republishes elements while a predicate closure indicates publishing should continue.
    ///
    /// The publisher finishes when the closure returns `false`.
    ///
    /// - Parameter predicate: A closure that takes an element as its parameter and returns a Boolean value indicating whether publishing should continue.
    /// - Returns: A publisher that passes through elements until the predicate indicates publishing should finish.
    public func prefix(while predicate: @escaping (Self.Output) -> Bool) -> Publishers.PrefixWhile<Self> {
        return Publishers.PrefixWhile(upstream: self, predicate: predicate)
    }

    /// Republishes elements while a error-throwing predicate closure indicates publishing should continue.
    ///
    /// The publisher finishes when the closure returns `false`. If the closure throws, the publisher fails with the thrown error.
    ///
    /// - Parameter predicate: A closure that takes an element as its parameter and returns a Boolean value indicating whether publishing should continue.
    /// - Returns: A publisher that passes through elements until the predicate throws or indicates publishing should finish.
    public func tryPrefix(while predicate: @escaping (Self.Output) throws -> Bool) -> Publishers.TryPrefixWhile<Self> {
        return Publishers.TryPrefixWhile(upstream: self, predicate: predicate)
    }
}
