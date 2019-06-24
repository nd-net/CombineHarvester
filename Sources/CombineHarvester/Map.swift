
extension Publishers {
    /// A publisher that transforms all elements from the upstream publisher with a provided closure.
    public struct Map<Upstream, Output>: Publisher where Upstream: Publisher {
        public typealias Failure = Upstream.Failure

        /// The publisher from which this publisher receives elements.
        public let upstream: Upstream

        /// The closure that transforms elements from the upstream publisher.
        public let transform: (Upstream.Output) -> Output

        /// This function is called to attach the specified `Subscriber` to this `Publisher` by `subscribe(_:)`
        ///
        /// - SeeAlso: `subscribe(_:)`
        /// - Parameters:
        ///     - subscriber: The subscriber to attach to this `Publisher`.
        ///                   once attached it can begin to receive values.
        public func receive<S>(subscriber: S) where Output == S.Input, S: Subscriber, Upstream.Failure == S.Failure {
            let nestedSubscriber = AnySubscriber<Upstream.Output, Upstream.Failure>(
                receiveSubscription: subscriber.receive(subscription:),
                receiveValue: { subscriber.receive(self.transform($0)) },
                receiveCompletion: subscriber.receive(completion:)
            )
            self.upstream.receive(subscriber: nestedSubscriber)
        }
    }

    /// A publisher that transforms all elements from the upstream publisher with a provided error-throwing closure.
    public struct TryMap<Upstream, Output>: Publisher where Upstream: Publisher {
        public typealias Failure = Error

        /// The publisher from which this publisher receives elements.
        public let upstream: Upstream

        /// The error-throwing closure that transforms elements from the upstream publisher.
        public let transform: (Upstream.Output) throws -> Output

        public func receive<S>(subscriber: S) where Output == S.Input, S: Subscriber, S.Failure == Publishers.TryMap<Upstream, Output>.Failure {
            var subscription: Subscription?
            let nestedSubscriber = AnySubscriber<Upstream.Output, Upstream.Failure>(
                receiveSubscription: {
                    subscription = $0
                    subscriber.receive(subscription: $0)
                },
                receiveValue: {
                    do {
                        return subscriber.receive(try self.transform($0))
                    } catch {
                        subscription?.cancel()
                        subscriber.receive(completion: .failure(error))
                        return .none
                    }
                },
                receiveCompletion: {
                    subscription = nil
                    switch $0 {
                    case .finished:
                        subscriber.receive(completion: .finished)
                    case let .failure(error):
                        subscriber.receive(completion: .failure(error))
                    }
                }
            )
            upstream.receive(subscriber: nestedSubscriber)
        }
    }
}

extension Publishers.Map {
    public func map<T>(_ transform: @escaping (Output) -> T) -> Publishers.Map<Upstream, T> {
        return Publishers.Map(upstream: self.upstream, transform: { transform(self.transform($0)) })
    }

    public func tryMap<T>(_ transform: @escaping (Output) throws -> T) -> Publishers.TryMap<Upstream, T> { return Publishers.TryMap(upstream: self.upstream, transform: { try transform(self.transform($0)) })
    }
}

extension Publishers.TryMap {
    public func map<T>(_ transform: @escaping (Output) -> T) -> Publishers.TryMap<Upstream, T> {
        return Publishers.TryMap(upstream: self.upstream, transform: { transform(try self.transform($0)) })
    }

    public func tryMap<T>(_ transform: @escaping (Output) throws -> T) -> Publishers.TryMap<Upstream, T> {
        return Publishers.TryMap(upstream: self.upstream, transform: { try transform(try self.transform($0)) })
    }
}

extension Publisher {
    /// Transforms all elements from the upstream publisher with a provided closure.
    ///
    /// - Parameter transform: A closure that takes one element as its parameter and returns a new element.
    /// - Returns: A publisher that uses the provided closure to map elements from the upstream publisher to new elements that it then publishes.
    public func map<T>(_ transform: @escaping (Self.Output) -> T) -> Publishers.Map<Self, T> {
        return Publishers.Map(upstream: self, transform: transform)
    }

    /// Transforms all elements from the upstream publisher with a provided error-throwing closure.
    ///
    /// If the `transform` closure throws an error, the publisher fails with the thrown error.
    /// - Parameter transform: A closure that takes one element as its parameter and returns a new element.
    /// - Returns: A publisher that uses the provided closure to map elements from the upstream publisher to new elements that it then publishes.
    public func tryMap<T>(_ transform: @escaping (Self.Output) throws -> T) -> Publishers.TryMap<Self, T> {
        return Publishers.TryMap(upstream: self, transform: transform)
    }
}

extension Publisher {
    /// Replaces nil elements in the stream with the provided element.
    ///
    /// - Parameter output: The element to use when replacing `nil`.
    /// - Returns: A publisher that replaces `nil` elements from the upstream publisher with the provided element.
    public func replaceNil<T>(with output: T) -> Publishers.Map<Self, T> where Self.Output == T? {
        return self.map { $0 ?? output }
    }
}
