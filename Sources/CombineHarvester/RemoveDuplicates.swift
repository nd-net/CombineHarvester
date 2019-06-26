
extension Publishers {
    public struct RemoveDuplicates<Upstream>: Publisher where Upstream: Publisher {
        public typealias Output = Upstream.Output
        public typealias Failure = Upstream.Failure

        public let upstream: Upstream

        public let predicate: (Upstream.Output, Upstream.Output) -> Bool

        public func receive<S>(subscriber: S) where S: Subscriber, Upstream.Failure == S.Failure, Upstream.Output == S.Input {
            var previous: Output?
            upstream.compactMap { value -> Output? in
                guard let prev = previous else {
                    previous = value
                    return value
                }
                if self.predicate(prev, value) {
                    return nil
                } else {
                    previous = value
                    return value
                }
            }.subscribe(subscriber)
        }
    }

    public struct TryRemoveDuplicates<Upstream>: Publisher where Upstream: Publisher {
        public typealias Output = Upstream.Output
        public typealias Failure = Error

        public let upstream: Upstream

        public let predicate: (Upstream.Output, Upstream.Output) throws -> Bool

        public func receive<S>(subscriber: S) where S: Subscriber, Upstream.Output == S.Input, S.Failure == Publishers.TryRemoveDuplicates<Upstream>.Failure {
            var previous: Output?
            upstream.tryCompactMap { value -> Output? in
                guard let prev = previous else {
                    previous = value
                    return value
                }
                if try self.predicate(prev, value) {
                    return nil
                } else {
                    previous = value
                    return value
                }
            }.subscribe(subscriber)
        }
    }
}

extension Publisher {
    public func removeDuplicates(by predicate: @escaping (Self.Output, Self.Output) -> Bool) -> Publishers.RemoveDuplicates<Self> {
        return Publishers.RemoveDuplicates<Self>(upstream: self, predicate: predicate)
    }

    public func tryRemoveDuplicates(by predicate: @escaping (Self.Output, Self.Output) throws -> Bool) -> Publishers.TryRemoveDuplicates<Self> {
        return Publishers.TryRemoveDuplicates<Self>(upstream: self, predicate: predicate)
    }
}

extension Publisher where Self.Output: Equatable {
    /// Publishes only elements that don’t match the previous element.
    ///
    /// - Returns: A publisher that consumes — rather than publishes — duplicate elements.
    public func removeDuplicates() -> Publishers.RemoveDuplicates<Self> {
        return self.removeDuplicates(by: ==)
    }
}
