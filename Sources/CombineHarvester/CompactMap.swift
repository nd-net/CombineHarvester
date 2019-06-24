
extension Publishers {
    /// A publisher that republishes all non-`nil` results of calling a closure with each received element.
    public struct CompactMap<Upstream, Output>: Publisher where Upstream: Publisher {
        public typealias Failure = Upstream.Failure

        /// The publisher from which this publisher receives elements.
        public let upstream: Upstream

        /// A closure that receives values from the upstream publisher and returns optional values.
        public let transform: (Upstream.Output) -> Output?

        public func receive<S>(subscriber: S) where Output == S.Input, S: Subscriber, Upstream.Failure == S.Failure {
            let transformingSubscriber = TransformingSubscriber<Upstream.Output, Upstream.Failure, Output, Failure>(
                subscriber: subscriber,
                transformRequest: { [.demand($0)] },
                transformValue: { value in
                    guard let transformed = self.transform(value) else {
                        return [.demand(.max(1))]
                    }
                    return [.value(transformed)]
                }, transformCompletion: { completion in
                    switch completion {
                    case .finished:
                        return [.finished]
                    case let .failure(error):
                        return [.failure(error)]
                    }
                }
            )

            upstream.receive(subscriber: transformingSubscriber)
        }
    }

    /// A publisher that republishes all non-`nil` results of calling an error-throwing closure with each received element.
    public struct TryCompactMap<Upstream, Output>: Publisher where Upstream: Publisher {
        public typealias Failure = Error

        /// The publisher from which this publisher receives elements.
        public let upstream: Upstream

        /// an error-throwing closure that receives values from the upstream publisher and returns optional values.
        ///
        /// If this closure throws an error, the publisher fails.
        public let transform: (Upstream.Output) throws -> Output?

        public func receive<S>(subscriber: S) where Output == S.Input, S: Subscriber, S.Failure == Failure {
            let transformingSubscriber = TransformingSubscriber<Upstream.Output, Upstream.Failure, Output, Failure>(
                subscriber: subscriber,
                transformRequest: { [.demand($0)] },
                transformValue: { value in
                    do {
                        guard let transformed = try self.transform(value) else {
                            return [.demand(.max(1))]
                        }
                        return [.value(transformed)]
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
            )

            upstream.receive(subscriber: transformingSubscriber)
        }
    }
}

extension Publishers.CompactMap {
    public func compactMap<T>(_ transform: @escaping (Output) -> T?) -> Publishers.CompactMap<Upstream, T> {
        return Publishers.CompactMap(upstream: self.upstream, transform: {
            guard let transformed = self.transform($0) else {
                return nil
            }
            return transform(transformed)
        })
    }

    public func map<T>(_ transform: @escaping (Output) -> T) -> Publishers.CompactMap<Upstream, T> {
        return Publishers.CompactMap(upstream: self.upstream, transform: {
            guard let transformed = self.transform($0) else {
                return nil
            }
            return transform(transformed)
        })
    }
}

extension Publishers.TryCompactMap {
    public func compactMap<T>(_ transform: @escaping (Output) throws -> T?) -> Publishers.TryCompactMap<Upstream, T> {
        return Publishers.TryCompactMap(upstream: self.upstream, transform: {
            guard let transformed = try self.transform($0) else {
                return nil
            }
            return try transform(transformed)
        })
    }
}

extension Publisher {
    /// Calls a closure with each received element and publishes any returned optional that has a value.
    ///
    /// - Parameter transform: A closure that receives a value and returns an optional value.
    /// - Returns: A publisher that republishes all non-`nil` results of calling the transform closure.
    public func compactMap<T>(_ transform: @escaping (Self.Output) -> T?) -> Publishers.CompactMap<Self, T> {
        return Publishers.CompactMap(upstream: self, transform: transform)
    }

    /// Calls an error-throwing closure with each received element and publishes any returned optional that has a value.
    ///
    /// If the closure throws an error, the publisher cancels the upstream and sends the thrown error to the downstream receiver as a `Failure`.
    /// - Parameter transform: an error-throwing closure that receives a value and returns an optional value.
    /// - Returns: A publisher that republishes all non-`nil` results of calling the transform closure.
    public func tryCompactMap<T>(_ transform: @escaping (Self.Output) throws -> T?) -> Publishers.TryCompactMap<Self, T> {
        return Publishers.TryCompactMap(upstream: self, transform: transform)
    }
}
