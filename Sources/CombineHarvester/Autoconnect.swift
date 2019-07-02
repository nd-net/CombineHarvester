extension Publishers {
    /// A publisher that automatically connects and disconnects from this connectable publisher.
    public class Autoconnect<Upstream: ConnectablePublisher>: Publisher {
        public typealias Output = Upstream.Output
        public typealias Failure = Upstream.Failure

        /// The publisher from which this publisher receives elements.
        public final let upstream: Upstream

        public init(_ upstream: Upstream) {
            self.upstream = upstream
        }

        public func receive<S: Subscriber>(subscriber: S) where Failure == S.Failure, Output == S.Input {
            var connection: Cancellable?
            self.upstream.subscribe(TransformingSubscriber(
                subscriber: subscriber,
                transformRequest: { demand in
                    if demand == .none {
                        return [.demand(.none)]
                    }
                    connection?.cancel()
                    connection = self.upstream.connect()
                    return [.demand(demand)]
                }, transformValue: { value in
                    [.value(value)]
                }, transformCompletion: { completion in
                    connection?.cancel()
                    switch completion {
                    case .finished:
                        return [.finished]
                    case let .failure(error):
                        return [.failure(error)]
                    }
                }
            ))
        }
    }
}

extension Publishers.Autoconnect: Equatable where Upstream: Equatable {
    public static func == (lhs: Publishers.Autoconnect<Upstream>, rhs: Publishers.Autoconnect<Upstream>) -> Bool {
        return lhs.upstream == rhs.upstream
    }
}

extension ConnectablePublisher {
    /// Automates the process of connecting or disconnecting from this connectable publisher.
    ///
    /// Use `autoconnect()` to simplify working with `ConnectablePublisher` instances, such as those created with `makeConnectable()`.
    ///
    ///     let autoconnectedPublisher = somePublisher
    ///         .makeConnectable()
    ///         .autoconnect()
    ///         .subscribe(someSubscriber)
    ///
    /// - Returns: A publisher which automatically connects to its upstream connectable publisher.
    public func autoconnect() -> Publishers.Autoconnect<Self> {
        return Publishers.Autoconnect(self)
    }
}
