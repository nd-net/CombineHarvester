
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

        private func print(_ items: Any...) {
            guard var stream = self.stream else {
                return
            }

            var string = self.prefix
            if !string.isEmpty {
                string += " "
            }
            string += items.map(String.init(describing:))
                .joined(separator: " ")
            string += "\n"

            stream.write(string)
        }

        private func print(subscription: Subscription) {
            self.print("receive(subscription:", subscription, ")")
        }

        private func print(value: Output) {
            self.print("receive(", value, ")")
        }

        private func print(completion: Subscribers.Completion<Failure>) {
            self.print("receive(completion:", completion, ")")
        }

        private func printCancellation() {
            self.print("cancel()")
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
                              receiveRequest: nil)
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
