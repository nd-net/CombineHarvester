extension Publishers {
    /// A publisher that only publishes the last element of a stream, after the stream finishes.
    public struct Last<Upstream>: Publisher where Upstream: Publisher {
        public typealias Output = Upstream.Output
        public typealias Failure = Upstream.Failure

        /// The publisher from which this publisher receives elements.
        public let upstream: Upstream
        public func receive<S>(subscriber: S) where S: Subscriber, Upstream.Failure == S.Failure, Upstream.Output == S.Input {
            var didRequest = false
            var previousValue: Output?
            self.upstream.subscribe(TransformingSubscriber(
                subscriber: subscriber,
                transformRequest: { demand in
                    guard demand > .none, !didRequest else {
                        return [.demand(.none)]
                    }
                    didRequest = true
                    return [.demand(.unlimited)]
                }, transformValue: { value in
                    previousValue = value
                    return [.demand(.unlimited)]
                }, transformCompletion: { completion in
                    switch completion {
                    case .finished:
                        if let value = previousValue {
                            return [.value(value), .finished]
                        } else {
                            return [.finished]
                        }
                    case let .failure(error):
                        return [.failure(error)]
                    }
                }
            ))
        }
    }
}

extension Publishers {
    /// A publisher that only publishes the last element of a stream that satisfies a predicate closure, once the stream finishes.
    public struct LastWhere<Upstream>: Publisher where Upstream: Publisher {
        public typealias Output = Upstream.Output
        public typealias Failure = Upstream.Failure
        public let upstream: Upstream

        /// The closure that determines whether to publish an element.
        public let predicate: (Upstream.Output) -> Bool

        public func receive<S>(subscriber: S) where S: Subscriber, Upstream.Failure == S.Failure, Upstream.Output == S.Input {
            return self.upstream
                .filter(self.predicate)
                .last()
                .subscribe(subscriber)
        }
    }

    /// A publisher that only publishes the last element of a stream that satisfies a error-throwing predicate closure, once the stream finishes.
    public struct TryLastWhere<Upstream>: Publisher where Upstream: Publisher {
        public typealias Output = Upstream.Output
        public typealias Failure = Error

        /// The publisher from which this publisher receives elements.
        public let upstream: Upstream

        /// The error-throwing closure that determines whether to publish an element.
        public let predicate: (Upstream.Output) throws -> Bool

        public func receive<S>(subscriber: S) where S: Subscriber, Upstream.Output == S.Input, S.Failure == Publishers.TryLastWhere<Upstream>.Failure {
            return self.upstream
                .tryFilter(self.predicate)
                .last()
                .subscribe(subscriber)
        }
    }
}

extension Publishers.Last: Equatable where Upstream: Equatable {
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

extension Publisher {
    /// Only publishes the last element of a stream that satisfies a predicate closure, after the stream finishes.
    /// - Parameter predicate: A closure that takes an element as its parameter and returns a Boolean value indicating whether to publish the element.
    /// - Returns: A publisher that only publishes the last element satisfying the given predicate.
    public func last(where predicate: @escaping (Self.Output) -> Bool) -> Publishers.LastWhere<Self> {
        return Publishers.LastWhere(upstream: self, predicate: predicate)
    }

    /// Only publishes the last element of a stream that satisfies a error-throwing predicate closure, after the stream finishes.
    ///
    /// If the predicate closure throws, the publisher fails with the thrown error.
    /// - Parameter predicate: A closure that takes an element as its parameter and returns a Boolean value indicating whether to publish the element.
    /// - Returns: A publisher that only publishes the last element satisfying the given predicate.
    public func tryLast(where predicate: @escaping (Self.Output) throws -> Bool) -> Publishers.TryLastWhere<Self> {
        return Publishers.TryLastWhere(upstream: self, predicate: predicate)
    }
}
