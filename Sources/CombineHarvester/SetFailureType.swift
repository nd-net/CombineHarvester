
extension Publishers {
    /// A publisher that appears to send a specified failure type.
    ///
    /// The publisher cannot actually fail with the specified type and instead just finishes normally. Use this publisher type when you need to match the error types for two mismatched publishers.
    public struct SetFailureType<Upstream, Failure>: Publisher where Upstream: Publisher, Failure: Error, Upstream.Failure == Never {
        public typealias Output = Upstream.Output

        /// The publisher from which this publisher receives elements.
        public let upstream: Upstream

        /// Creates a publisher that appears to send a specified failure type.
        ///
        /// - Parameter upstream: The publisher from which this publisher receives elements.
        public init(upstream: Upstream) {
            self.upstream = upstream
        }

        public func receive<S>(subscriber: S) where Failure == S.Failure, S: Subscriber, Output == S.Input {
            let nestedSubscriber = AnySubscriber<Upstream.Output, Upstream.Failure>(
                receiveSubscription: subscriber.receive(subscription:),
                receiveValue: subscriber.receive,
                receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        subscriber.receive(completion: .finished)
                    case .failure:
                        // this cannot happen aince the failure is Never
                        fatalError()
                    }
                }
            )
            self.upstream.receive(subscriber: nestedSubscriber)
        }

        public func setFailureType<E>(to _: E.Type) -> Publishers.SetFailureType<Upstream, E> where E: Error {
            return self as? SetFailureType<Upstream, E> ?? SetFailureType<Upstream, E>(upstream: self.upstream)
        }
    }
}

extension Publishers.SetFailureType: Equatable where Upstream: Equatable {
    public static func == (lhs: Publishers.SetFailureType<Upstream, Failure>, rhs: Publishers.SetFailureType<Upstream, Failure>) -> Bool {
        return lhs.upstream == rhs.upstream
    }
}

extension Publisher where Self.Failure == Never {
    /// Changes the failure type declared by the upstream publisher.
    ///
    /// The publisher returned by this method cannot actually fail with the specified type and instead just finishes normally. Instead, you use this method when you need to match the error types of two mismatched publishers.
    ///
    /// - Parameter failureType: The `Failure` type presented by this publisher.
    /// - Returns: A publisher that appears to send the specified failure type.
    public func setFailureType<E>(to _: E.Type) -> Publishers.SetFailureType<Self, E> where E: Error {
        return Publishers.SetFailureType(upstream: self)
    }
}
