
extension Publishers {
    /// A publisher that republishes items from another publisher only if each new item is in increasing order from the previously-published item.
    public struct Comparison<Upstream>: Publisher where Upstream: Publisher {
        public typealias Output = Upstream.Output
        public typealias Failure = Upstream.Failure

        /// The publisher that this publisher receives elements from.
        public let upstream: Upstream

        /// A closure that receives two elements and returns `true` if they are in increasing order.
        public let areInIncreasingOrder: (Upstream.Output, Upstream.Output) -> Bool

        public func receive<S>(subscriber: S) where S: Subscriber, Upstream.Failure == S.Failure, Upstream.Output == S.Input {
            var didRequest = false
            var result: Output?
            self.upstream.subscribe(TransformingSubscriber(
                subscriber: subscriber,
                transformRequest: { demand in
                    guard demand > .none, !didRequest else {
                        return [.demand(.none)]
                    }
                    didRequest = true
                    return [.demand(.unlimited)]
                }, transformValue: { value in
                    guard let existing = result else {
                        result = value
                        return [.demand(.unlimited)]
                    }
                    if self.areInIncreasingOrder(existing, value) {
                        result = value
                    }
                    return [.demand(.unlimited)]
                }, transformCompletion: { completion in
                    switch completion {
                    case .finished:
                        if let result = result {
                            return [.value(result), .finished]
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

    /// A publisher that republishes items from another publisher only if each new item is in increasing order from the previously-published item, and fails if the ordering logic throws an error.
    public struct TryComparison<Upstream>: Publisher where Upstream: Publisher {
        public typealias Output = Upstream.Output
        public typealias Failure = Error

        /// The publisher that this publisher receives elements from.
        public let upstream: Upstream

        /// A closure that receives two elements and returns `true` if they are in increasing order.
        public let areInIncreasingOrder: (Upstream.Output, Upstream.Output) throws -> Bool

        public func receive<S>(subscriber: S) where S: Subscriber, Upstream.Output == S.Input, S.Failure == Publishers.TryComparison<Upstream>.Failure {
            var didRequest = false
            var result: Output?
            self.upstream.subscribe(TransformingSubscriber(
                subscriber: subscriber,
                transformRequest: { demand in
                    guard demand > .none, !didRequest else {
                        return [.demand(.none)]
                    }
                    didRequest = true
                    return [.demand(.unlimited)]
                }, transformValue: { value in
                    guard let existing = result else {
                        result = value
                        return [.demand(.unlimited)]
                    }
                    do {
                        if try self.areInIncreasingOrder(existing, value) {
                            result = value
                        }
                        return [.demand(.unlimited)]
                    } catch {
                        return [.failure(error)]
                    }
                }, transformCompletion: { completion in
                    switch completion {
                    case .finished:
                        if let result = result {
                            return [.value(result), .finished]
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

extension Publisher where Self.Output: Comparable {
    /// Publishes the minimum value received from the upstream publisher, after it finishes.
    ///
    /// After this publisher receives a request for more than 0 items, it requests unlimited items from its upstream publisher.
    /// - Returns: A publisher that publishes the minimum value received from the upstream publisher, after the upstream publisher finishes.
    public func min() -> Publishers.Comparison<Self> {
        return self.min(by: <)
    }

    /// Publishes the maximum value received from the upstream publisher, after it finishes.
    ///
    /// After this publisher receives a request for more than 0 items, it requests unlimited items from its upstream publisher.
    /// - Returns: A publisher that publishes the maximum value received from the upstream publisher, after the upstream publisher finishes.
    public func max() -> Publishers.Comparison<Self> {
        return self.max(by: <)
    }
}

extension Publisher {
    /// Publishes the minimum value received from the upstream publisher, after it finishes.
    ///
    /// After this publisher receives a request for more than 0 items, it requests unlimited items from its upstream publisher.
    /// - Parameter areInIncreasingOrder: A closure that receives two elements and returns `true` if they are in increasing order.
    /// - Returns: A publisher that publishes the minimum value received from the upstream publisher, after the upstream publisher finishes.
    public func min(by areInIncreasingOrder: @escaping (Self.Output, Self.Output) -> Bool) -> Publishers.Comparison<Self> {
        return Publishers.Comparison(upstream: self, areInIncreasingOrder: { areInIncreasingOrder($1, $0) })
    }

    /// Publishes the minimum value received from the upstream publisher, using the provided error-throwing closure to order the items.
    ///
    /// After this publisher receives a request for more than 0 items, it requests unlimited items from its upstream publisher.
    /// - Parameter areInIncreasingOrder: A throwing closure that receives two elements and returns `true` if they are in increasing order. If this closure throws, the publisher terminates with a `Failure`.
    /// - Returns: A publisher that publishes the minimum value received from the upstream publisher, after the upstream publisher finishes.
    public func tryMin(by areInIncreasingOrder: @escaping (Self.Output, Self.Output) throws -> Bool) -> Publishers.TryComparison<Self> {
        return Publishers.TryComparison(upstream: self, areInIncreasingOrder: { try areInIncreasingOrder($1, $0) })
    }

    /// Publishes the maximum value received from the upstream publisher, using the provided ordering closure.
    ///
    /// After this publisher receives a request for more than 0 items, it requests unlimited items from its upstream publisher.
    /// - Parameter areInIncreasingOrder: A closure that receives two elements and returns `true` if they are in increasing order.
    /// - Returns: A publisher that publishes the maximum value received from the upstream publisher, after the upstream publisher finishes.
    public func max(by areInIncreasingOrder: @escaping (Self.Output, Self.Output) -> Bool) -> Publishers.Comparison<Self> {
        return Publishers.Comparison(upstream: self, areInIncreasingOrder: areInIncreasingOrder)
    }

    /// Publishes the maximum value received from the upstream publisher, using the provided error-throwing closure to order the items.
    ///
    /// After this publisher receives a request for more than 0 items, it requests unlimited items from its upstream publisher.
    /// - Parameter areInIncreasingOrder: A throwing closure that receives two elements and returns `true` if they are in increasing order. If this closure throws, the publisher terminates with a `Failure`.
    /// - Returns: A publisher that publishes the maximum value received from the upstream publisher, after the upstream publisher finishes.
    public func tryMax(by areInIncreasingOrder: @escaping (Self.Output, Self.Output) throws -> Bool) -> Publishers.TryComparison<Self> {
        return Publishers.TryComparison(upstream: self, areInIncreasingOrder: areInIncreasingOrder)
    }
}
