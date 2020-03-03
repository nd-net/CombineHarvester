
extension Publishers {
    /// A publisher that prints log messages for all publishing events, optionally prefixed with a given string.
    ///
    /// This publisher prints log messages when receiving the following events:
    /// * subscription
    /// * value
    /// * normal completion
    /// * failure
    /// * cancellation
    public struct Print<Upstream: Publisher>: Publisher {
        public typealias Output = Upstream.Output
        public typealias Failure = Upstream.Failure

        /// A string with which to prefix all log messages.
        public let prefix: String

        /// The publisher from which this publisher receives elements.
        public let upstream: Upstream

        public let stream: TextOutputStream?

        /// Creates a publisher that prints log messages for all publishing events.
        ///
        /// - Parameters:
        ///   - upstream: The publisher from which this publisher receives elements.
        ///   - prefix: A string with which to prefix all log messages.
        public init(upstream: Upstream, prefix: String, to stream: TextOutputStream? = nil) {
            self.upstream = upstream
            self.prefix = prefix
            self.stream = stream
        }

        private func print(items: Any...) {
            var stream = self.stream ?? ""

            if !self.prefix.isEmpty {
                stream.write(self.prefix)
                stream.write(": ")
            }
            for item in items {
                stream.write(String(describing: item))
            }
            stream.write("\n")

            if self.stream == nil {
                Swift.print(stream)
            }
        }

        private func print(subscription: Subscription) {
            self.print(items: "receive subscription: ", subscription)
        }

        private func print(value: Output) {
            self.print(items: "receive value: (", value, ")")
        }

        private func print(completion: Subscribers.Completion<Failure>) {
            switch completion {
            case .finished:
                self.print(items: "receive finished")
            case let .failure(error):
                self.print(items: "receive error: (", error, ")")
            }
        }

        private func printCancellation() {
            self.print(items: "receive cancel")
        }

        private func printRequest(demand: Subscribers.Demand) {
            self.print(items: "request ", demand)
        }

        public func receive<S: Subscriber>(subscriber: S) where Upstream.Failure == S.Failure, Upstream.Output == S.Input {
            guard self.stream != nil else {
                self.upstream.subscribe(subscriber)
                return
            }
            self.upstream
                .handleEvents(receiveSubscription: self.print(subscription:),
                              receiveOutput: self.print(value:),
                              receiveCompletion: self.print(completion:),
                              receiveCancel: self.printCancellation,
                              receiveRequest: self.printRequest)
                .subscribe(subscriber)
        }
    }
}

extension Publisher {
    /// Prints log messages for all publishing events.
    ///
    /// - Parameter prefix: A string with which to prefix all log messages. Defaults to an empty string.
    /// - Returns: A publisher that prints log messages for all publishing events.
    public func print(_ prefix: String = "", to stream: TextOutputStream? = nil) -> Publishers.Print<Self> {
        return Publishers.Print(upstream: self, prefix: prefix, to: stream)
    }
}
