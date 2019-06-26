
extension Publishers {
    /// A publisher that publishes the first element of a stream, then finishes.
    public struct First<Upstream>: Publisher where Upstream: Publisher {
        public typealias Output = Upstream.Output
        public typealias Failure = Upstream.Failure

        /// The publisher from which this publisher receives elements.
        public let upstream: Upstream

        public func receive<S>(subscriber: S) where S: Subscriber, Upstream.Failure == S.Failure, Upstream.Output == S.Input {
            self.upstream.prefix(1)
                .subscribe(subscriber)
        }
    }

    /// A publisher that only publishes the first element of a stream to satisfy a predicate closure.
    public struct FirstWhere<Upstream>: Publisher where Upstream: Publisher {
        public typealias Output = Upstream.Output
        public typealias Failure = Upstream.Failure

        /// The publisher from which this publisher receives elements.
        public let upstream: Upstream

        /// The closure that determines whether to publish an element.
        public let predicate: (Upstream.Output) -> Bool

        public func receive<S>(subscriber: S) where S: Subscriber, Upstream.Failure == S.Failure, Upstream.Output == S.Input {
            return self.upstream
                .filter(self.predicate)
                .first()
                .subscribe(subscriber)
        }
    }

    /// A publisher that only publishes the first element of a stream to satisfy a throwing predicate closure.
    public struct TryFirstWhere<Upstream>: Publisher where Upstream: Publisher {
        public typealias Output = Upstream.Output
        public typealias Failure = Error

        /// The publisher from which this publisher receives elements.
        public let upstream: Upstream

        /// The error-throwing closure that determines whether to publish an element.
        public let predicate: (Upstream.Output) throws -> Bool

        public func receive<S>(subscriber: S) where S: Subscriber, Upstream.Output == S.Input, S.Failure == Publishers.TryFirstWhere<Upstream>.Failure {
            return self.upstream
                .tryFilter(self.predicate)
                .first()
                .subscribe(subscriber)
        }
    }
}

extension Publishers.First: Equatable where Upstream: Equatable {
    public static func == (lhs: Publishers.First<Upstream>, rhs: Publishers.First<Upstream>) -> Bool {
        return lhs.upstream == rhs.upstream
    }
}

extension Publisher {
    /// Publishes the first element of a stream, then finishes.
    ///
    /// If this publisher doesn’t receive any elements, it finishes without publishing.
    /// - Returns: A publisher that only publishes the first element of a stream.
    public func first() -> Publishers.First<Self> {
        return Publishers.First(upstream: self)
    }

    /// Publishes the first element of a stream to satisfy a predicate closure, then finishes.
    ///
    /// The publisher ignores all elements after the first. If this publisher doesn’t receive any elements, it finishes without publishing.
    /// - Parameter predicate: A closure that takes an element as a parameter and returns a Boolean value that indicates whether to publish the element.
    /// - Returns: A publisher that only publishes the first element of a stream that satifies the predicate.
    public func first(where predicate: @escaping (Self.Output) -> Bool) -> Publishers.FirstWhere<Self> {
        return Publishers.FirstWhere(upstream: self, predicate: predicate)
    }

    /// Publishes the first element of a stream to satisfy a throwing predicate closure, then finishes.
    ///
    /// The publisher ignores all elements after the first. If this publisher doesn’t receive any elements, it finishes without publishing. If the predicate closure throws, the publisher fails with an error.
    /// - Parameter predicate: A closure that takes an element as a parameter and returns a Boolean value that indicates whether to publish the element.
    /// - Returns: A publisher that only publishes the first element of a stream that satifies the predicate.
    public func tryFirst(where predicate: @escaping (Self.Output) throws -> Bool) -> Publishers.TryFirstWhere<Self> {
        return Publishers.TryFirstWhere(upstream: self, predicate: predicate)
    }
}
