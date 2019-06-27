/// A publisher that provides an explicit means of connecting and canceling publication.
///
/// Use `makeConnectable()` to create a `ConnectablePublisher` from any publisher whose failure type is `Never`.
public protocol ConnectablePublisher: Publisher {
    /// Connects to the publisher and returns a `Cancellable` instance with which to cancel publishing.
    ///
    /// - Returns: A `Cancellable` instance that can be used to cancel publishing.
    func connect() -> Cancellable
}

extension Publishers {
    public struct MakeConnectable<Upstream>: ConnectablePublisher where Upstream: Publisher {
        public typealias Output = Upstream.Output
        public typealias Failure = Upstream.Failure

        fileprivate let upstream: Upstream

        init(upstream: Upstream) {
            self.upstream = upstream
        }

        private class Connection: Cancellable {
            typealias ConnectionSubscription = TransformingSubscriber<Output, Failure, Output, Failure>

            var connected = false
            var subscription: ConnectionSubscription?

            public func receive<S: Subscriber>(subscriber: S) -> ConnectionSubscription where Upstream.Failure == S.Failure, Upstream.Output == S.Input {
                let result = TransformingSubscriber<Upstream.Output, Upstream.Failure, Output, Failure>(
                    subscriber: subscriber,
                    transformRequest: { [.demand($0)] },
                    transformValue: {
                        self.connected ? [.value($0)] : [.demand(.max(1))]
                    },
                    cancelled: { _ in
                        self.connected = false
                        self.subscription = nil
                    }
                )
                self.subscription = result
                return result
            }

            func connect() {
                self.connected = true
            }

            func cancel() {
                self.connected = false
            }
        }

        private let connection = Connection()

        public func receive<S: Subscriber>(subscriber: S) where Upstream.Failure == S.Failure, Upstream.Output == S.Input {
            self.upstream.receive(subscriber:
                self.connection.receive(subscriber: subscriber))
        }

        public func connect() -> Cancellable {
            let connection = self.connection
            connection.connect()
            return connection
        }
    }
}

extension Publisher where Self.Failure == Never {
    /// Creates a connectable wrapper around the publisher.
    ///
    /// - Returns: A `ConnectablePublisher` wrapping this publisher.
    public func makeConnectable() -> Publishers.MakeConnectable<Self> {
        return self as? Publishers.MakeConnectable<Self> ?? Publishers.MakeConnectable(upstream: self)
    }
}
