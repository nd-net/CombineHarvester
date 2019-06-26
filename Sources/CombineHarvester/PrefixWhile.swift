
extension Publishers {
    /// A publisher that republishes elements while a predicate closure indicates publishing should continue.
    public struct PrefixWhile<Upstream>: Publisher where Upstream: Publisher {
        public typealias Output = Upstream.Output
        public typealias Failure = Upstream.Failure

        /// The publisher from which this publisher receives elements.
        public let upstream: Upstream

        /// The closure that determines whether whether publishing should continue.
        public let predicate: (Upstream.Output) -> Bool

        public func receive<S>(subscriber: S) where S: Subscriber, Upstream.Failure == S.Failure, Upstream.Output == S.Input {
            self.upstream.subscribe(TransformingSubscriber(
                subscriber: subscriber,
                transformRequest: { [.demand($0)] },
                transformValue: { value in
                    if self.predicate(value) {
                        return [.value(value)]
                    }
                    return [.finished]
                }, transformCompletion: { completion in
                    switch completion {
                    case .finished:
                        return [.finished]
                    case let .failure(error):
                        return [.failure(error)]
                    }
                }
            )
            )
        }
    }

    /// A publisher that republishes elements while an error-throwing predicate closure indicates publishing should continue.
    public struct TryPrefixWhile<Upstream>: Publisher where Upstream: Publisher {
        public typealias Output = Upstream.Output
        public typealias Failure = Error

        /// The publisher from which this publisher receives elements.
        public let upstream: Upstream

        /// The error-throwing closure that determines whether publishing should continue.
        public let predicate: (Upstream.Output) throws -> Bool

        /// This function is called to attach the specified `Subscriber` to this `Publisher` by `subscribe(_:)`
        ///
        /// - SeeAlso: `subscribe(_:)`
        /// - Parameters:
        ///     - subscriber: The subscriber to attach to this `Publisher`.
        ///                   once attached it can begin to receive values.
        public func receive<S>(subscriber: S) where S: Subscriber, Upstream.Output == S.Input, S.Failure == Publishers.TryPrefixWhile<Upstream>.Failure {
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
                }, transformCompletion: { completion in
                    switch completion {
                    case .finished:
                        return [.finished]
                    case let .failure(error):
                        return [.failure(error)]
                    }
                }
            ))
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
