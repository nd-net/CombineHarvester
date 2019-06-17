
extension Publishers {
    /// A publisher that converts any failure from the upstream publisher into a new error.
    public struct MapError<Upstream, Failure>: Publisher where Upstream: Publisher, Failure: Error {
        /// The kind of values published by this publisher.
        public typealias Output = Upstream.Output

        /// The publisher from which this publisher receives elements.
        public let upstream: Upstream

        /// The closure that converts the upstream failure into a new error.
        public let transform: (Upstream.Failure) -> Failure

        public init(upstream: Upstream, _ map: @escaping (Upstream.Failure) -> Failure) {
            self.upstream = upstream
            self.transform = map
        }

        public func receive<S>(subscriber: S) where Failure == S.Failure, S: Subscriber, Output == S.Input {
            let nestedSubscriber = AnySubscriber<Upstream.Output, Upstream.Failure>(
                receiveSubscription: subscriber.receive(subscription:),
                receiveValue: subscriber.receive,
                receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        subscriber.receive(completion: .finished)
                    case let .failure(error):
                        let transformed = self.transform(error)
                        subscriber.receive(completion: .failure(transformed))
                    }
                }
            )
            self.upstream.receive(subscriber: nestedSubscriber)
        }
    }
}

extension Publisher {
    /// Converts any failure from the upstream publisher into a new error.
    ///
    /// Until the upstream publisher finishes normally or fails with an error, the returned publisher republishes all the elements it receives.
    ///
    /// - Parameter transform: A closure that takes the upstream failure as a parameter and returns a new error for the publisher to terminate with.
    /// - Returns: A publisher that replaces any upstream failure with a new error produced by the `transform` closure.
    public func mapError<E>(_ transform: @escaping (Self.Failure) -> E) -> Publishers.MapError<Self, E> where E: Error {
        return Publishers.MapError(upstream: self, transform)
    }
}
