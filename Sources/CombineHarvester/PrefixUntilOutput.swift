
extension Publishers {
    public struct PrefixUntilOutput<Upstream, Other>: Publisher where Upstream: Publisher, Other: Publisher {
        public typealias Output = Upstream.Output
        public typealias Failure = Upstream.Failure

        /// The publisher from which this publisher receives elements.
        public let upstream: Upstream

        /// Another publisher, whose first output causes this publisher to finish.
        public let other: Other

        public func receive<S>(subscriber: S) where S: Subscriber, Upstream.Failure == S.Failure, Upstream.Output == S.Input {
            var cancelOther: Cancellable?

            let transformingSubscriber = TransformingSubscriber<Upstream.Output, Upstream.Failure, Output, Failure>(
                subscriber: subscriber,
                transformRequest: { [.demand($0)] },
                transformValue: { [.value($0)] },
                cancelled: { _ in cancelOther?.cancel() }
            )
            let sink = self.other.first()
                .sink(receiveValue: { _ in transformingSubscriber.receive(completion: .finished) })
            cancelOther = sink
            return self.upstream.subscribe(transformingSubscriber)
        }
    }
}

extension Publishers.PrefixUntilOutput: Equatable where Upstream: Equatable, Other: Equatable {
}

extension Publisher {
    /// Republishes elements until another publisher emits an element.
    ///
    /// After the second publisher publishes an element, the publisher returned by this method finishes.
    ///
    /// - Parameter publisher: A second publisher.
    /// - Returns: A publisher that republishes elements until the second publisher publishes an element.
    public func prefix<P>(untilOutputFrom publisher: P) -> Publishers.PrefixUntilOutput<Self, P> where P: Publisher {
        return Publishers.PrefixUntilOutput(upstream: self, other: publisher)
    }
}
