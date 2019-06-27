
extension Publishers {
    /// A publisher that ignores elements from the upstream publisher until it receives an element from second publisher.
    public struct DropUntilOutput<Upstream, Other>: Publisher where Upstream: Publisher, Other: Publisher, Upstream.Failure == Other.Failure {
        public typealias Output = Upstream.Output
        public typealias Failure = Upstream.Failure

        /// The publisher that this publisher receives elements from.
        public let upstream: Upstream

        /// A publisher to monitor for its first emitted element.
        public let other: Other

        /// Creates a publisher that ignores elements from the upstream publisher until it receives an element from another publisher.
        ///
        /// - Parameters:
        ///   - upstream: A publisher to drop elements from while waiting for another publisher to emit elements.
        ///   - other: A publisher to monitor for its first emitted element.
        public init(upstream: Upstream, other: Other) {
            self.upstream = upstream
            self.other = other
        }

        public func receive<S: Subscriber>(subscriber: S) where Upstream.Output == S.Input, Other.Failure == S.Failure {
            var cancelOther: Cancellable?
            var cancelUpstream: Cancellable?
            var forward = false

            let transformingSubscriber = TransformingSubscriber<Upstream.Output, Upstream.Failure, Output, Failure>(
                subscriber: subscriber,
                transformRequest: { [.demand($0)] },
                transformValue: { forward ? [.value($0)] : [.demand(.max(1))] },
                cancelled: { _ in cancelOther?.cancel() }
            )
            cancelUpstream = transformingSubscriber
            let sink = self.other.first()
                .sink(receiveCompletion: { _ in
                    if !forward {
                        cancelUpstream?.cancel()
                    }
                }, receiveValue: { _ in forward = true })
            cancelOther = sink
            return self.upstream.subscribe(transformingSubscriber)
        }
    }
}

extension Publishers.DropUntilOutput: Equatable where Upstream: Equatable, Other: Equatable {
}

extension Publisher {
    /// Ignores elements from the upstream publisher until it receives an element from a second publisher.
    ///
    /// This publisher requests a single value from the upstream publisher, and it ignores (drops) all elements from that publisher until the upstream publisher produces a value. After the `other` publisher produces an element, this publisher cancels its subscription to the `other` publisher, and allows events from the `upstream` publisher to pass through.
    /// After this publisher receives a subscription from the upstream publisher, it passes through backpressure requests from downstream to the upstream publisher. If the upstream publisher acts on those requests before the other publisher produces an item, this publisher drops the elements it receives from the upstream publisher.
    ///
    /// - Parameter publisher: A publisher to monitor for its first emitted element.
    /// - Returns: A publisher that drops elements from the upstream publisher until the `other` publisher produces a value.
    public func drop<P>(untilOutputFrom publisher: P) -> Publishers.DropUntilOutput<Self, P> where P: Publisher, Self.Failure == P.Failure {
        return Publishers.DropUntilOutput(upstream: self, other: publisher)
    }
}
