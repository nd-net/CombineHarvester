
extension Publishers {
    /// A publisher that publishes the number of elements received from the upstream publisher.
    public struct Count<Upstream>: Publisher where Upstream: Publisher {
        public typealias Output = Int
        public typealias Failure = Upstream.Failure

        /// The publisher from which this publisher receives elements.
        public let upstream: Upstream

        public func receive<S>(subscriber: S) where S: Subscriber, Failure == S.Failure, S.Input == Output {
            var didRequest = false
            var count = 0
            self.upstream.subscribe(TransformingSubscriber(
                subscriber: subscriber,
                transformRequest: { demand in
                    guard demand > .none, !didRequest else {
                        return [.demand(.none)]
                    }
                    didRequest = true
                    return [.demand(.unlimited)]
                }, transformValue: { _ in
                    count += 1
                    return [.demand(.unlimited)]
                }, transformCompletion: { completion in
                    switch completion {
                    case .finished:
                        return [.value(count), .finished]
                    case let .failure(error):
                        return [.failure(error)]
                    }
                }
            ))
        }
    }
}

extension Publisher {
    /// Publishes the number of elements received from the upstream publisher.
    ///
    /// - Returns: A publisher that consumes all elements until the upstream publisher finishes, then emits a single
    /// value with the total number of elements received.
    public func count() -> Publishers.Count<Self> {
        return Publishers.Count(upstream: self)
    }
}
