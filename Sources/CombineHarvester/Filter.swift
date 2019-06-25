
extension Publishers {
    /// A publisher that republishes all elements that match a provided closure.
    public struct Filter<Upstream>: Publisher where Upstream: Publisher {
        public typealias Output = Upstream.Output
        public typealias Failure = Upstream.Failure

        /// The publisher from which this publisher receives elements.
        public let upstream: Upstream

        /// A closure that indicates whether to republish an element.
        public let isIncluded: (Upstream.Output) -> Bool

        public func receive<S>(subscriber: S) where S: Subscriber, Failure == S.Failure, Output == S.Input {
            let nestedSubscriber = TransformingSubscriber<Output, Failure, Output, Failure>(
                subscriber: subscriber,
                transformRequest: { [.demand($0)] },
                transformValue: { self.isIncluded($0) ? [.value($0)] : [.demand(.max(1))] },
                transformCompletion: {
                    switch $0 {
                    case .finished:
                        return [.finished]
                    case let .failure(error):
                        return [.failure(error)]
                    }
                }
            )
            upstream.subscribe(nestedSubscriber)
        }
    }

    /// A publisher that republishes all elements that match a provided error-throwing closure.
    public struct TryFilter<Upstream>: Publisher where Upstream: Publisher {
        public typealias Output = Upstream.Output
        public typealias Failure = Error

        /// The publisher from which this publisher receives elements.
        public let upstream: Upstream

        /// A error-throwing closure that indicates whether to republish an element.
        public let isIncluded: (Upstream.Output) throws -> Bool

        public func receive<S>(subscriber: S) where S: Subscriber, Upstream.Output == S.Input, S.Failure == Publishers.TryFilter<Upstream>.Failure {
            let nestedSubscriber = TransformingSubscriber<Output, Upstream.Failure, Output, Failure>(
                subscriber: subscriber,
                transformRequest: { [.demand($0)] },
                transformValue: { value in
                    do {
                        return try self.isIncluded(value) ? [.value(value)] : [.demand(.max(1))]
                    } catch {
                        return [.failure(error)]
                    }
                },
                transformCompletion: {
                    switch $0 {
                    case .finished:
                        return [.finished]
                    case let .failure(error):
                        return [.failure(error)]
                    }
                }
            )
            upstream.subscribe(nestedSubscriber)
        }
    }
}

extension Publishers.Filter {
    public func filter(_ isIncluded: @escaping (Output) -> Bool) -> Publishers.Filter<Upstream> {
        return Publishers.Filter(upstream: self.upstream, isIncluded: { self.isIncluded($0) && isIncluded($0) })
    }

    public func tryFilter(_ isIncluded: @escaping (Output) throws -> Bool) -> Publishers.TryFilter<Upstream> {
        return Publishers.TryFilter(upstream: self.upstream, isIncluded: {
            guard self.isIncluded($0) else {
                return false
            }
            return try isIncluded($0)
        })
    }
}

extension Publishers.TryFilter {
    public func filter(_ isIncluded: @escaping (Output) -> Bool) -> Publishers.TryFilter<Upstream> {
        return Publishers.TryFilter(upstream: self.upstream, isIncluded: { try self.isIncluded($0) && isIncluded($0) })
    }

    public func tryFilter(_ isIncluded: @escaping (Output) throws -> Bool) -> Publishers.TryFilter<Upstream> {
        return Publishers.TryFilter(upstream: self.upstream, isIncluded: {
            guard try self.isIncluded($0) else {
                return false
            }
            return try isIncluded($0)
        })
    }
}

extension Publisher {
    /// Republishes all elements that match a provided closure.
    ///
    /// - Parameter isIncluded: A closure that takes one element and returns a Boolean value indicating whether to republish the element.
    /// - Returns: A publisher that republishes all elements that satisfy the closure.
    public func filter(_ isIncluded: @escaping (Output) -> Bool) -> Publishers.Filter<Self> {
        return Publishers.Filter(upstream: self, isIncluded: isIncluded)
    }

    /// Republishes all elements that match a provided error-throwing closure.
    ///
    /// If the `isIncluded` closure throws an error, the publisher fails with that error.
    ///
    /// - Parameter isIncluded:  A closure that takes one element and returns a Boolean value indicating whether to republish the element.
    /// - Returns:  A publisher that republishes all elements that satisfy the closure.
    public func tryFilter(_ isIncluded: @escaping (Output) throws -> Bool) -> Publishers.TryFilter<Self> {
        return Publishers.TryFilter(upstream: self, isIncluded: isIncluded)
    }
}
