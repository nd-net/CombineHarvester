
extension Publishers {
    /// A publisher that raises a fatal error upon receiving any failure, and otherwise republishes all received input.
    ///
    /// Use this function for internal sanity checks that are active during testing but do not impact performance of shipping code.
    public struct AssertNoFailure<Upstream>: Publisher where Upstream: Publisher {
        public typealias Output = Upstream.Output
        public typealias Failure = Never

        /// The publisher from which this publisher receives elements.
        public let upstream: Upstream

        /// The string used at the beginning of the fatal error message.
        public let prefix: String

        /// The filename used in the error message.
        public let file: StaticString

        /// The line number used in the error message.
        public let line: UInt

        public func receive<S>(subscriber: S) where S: Subscriber, Output == S.Input, S.Failure == Failure {
            let nestedSubscriber = AnySubscriber<Upstream.Output, Upstream.Failure>(
                receiveSubscription: subscriber.receive(subscription:),
                receiveValue: subscriber.receive,
                receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        subscriber.receive(completion: .finished)
                    case let .failure(error):
                        fatalError("\(self.prefix) Received .failure(\(error))", file: self.file, line: self.line)
                    }
                }
            )
            self.upstream.receive(subscriber: nestedSubscriber)
        }
    }
}

extension Publisher {
    /// Raises a fatal error when its upstream publisher fails, and otherwise republishes all received input.
    ///
    /// Use this function for internal sanity checks that are active during testing but do not impact performance of shipping code.
    ///
    /// - Parameters:
    ///   - prefix: A string used at the beginning of the fatal error message.
    ///   - file: A filename used in the error message. This defaults to `#file`.
    ///   - line: A line number used in the error message. This defaults to `#line`.
    /// - Returns: A publisher that raises a fatal error when its upstream publisher fails.
    public func assertNoFailure(_ prefix: String = "", file: StaticString = #file, line: UInt = #line) -> Publishers.AssertNoFailure<Self> {
        return Publishers.AssertNoFailure(upstream: self, prefix: prefix, file: file, line: line)
    }
}
