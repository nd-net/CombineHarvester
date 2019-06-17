
extension Publishers {
    /// A publisher that immediately terminates with the specified error.
    public struct Fail<Output, Failure>: Publisher where Failure: Error {
        /// Creates a publisher that immediately terminates with the specified failure.
        ///
        /// - Parameter error: The failure to send when terminating the publisher.
        public init(error: Failure) {
            self.error = error
        }

        /// Creates publisher with the given output type, that immediately terminates with the specified failure.
        ///
        /// Use this initializer to create a `Fail` publisher that can work with subscribers or publishers that expect a given output type.
        /// - Parameters:
        ///   - outputType: The output type exposed by this publisher.
        ///   - failure: The failure to send when terminating the publisher.
        public init(outputType _: Output.Type, failure error: Failure) {
            self.error = error
        }

        /// The failure to send when terminating the publisher.
        public let error: Failure

        public func receive<S>(subscriber: S) where Output == S.Input, Failure == S.Failure, S: Subscriber {
            subscriber.receive(subscription: Subscriptions.empty)
            subscriber.receive(completion: .failure(self.error))
        }
    }
}

extension Publishers.Fail: Equatable where Failure: Equatable {
    /// Returns a Boolean value indicating whether two values are equal.
    ///
    /// Equality is the inverse of inequality. For any values `a` and `b`,
    /// `a == b` implies that `a != b` is `false`.
    ///
    /// - Parameters:
    ///   - lhs: A value to compare.
    ///   - rhs: Another value to compare.
    public static func == (lhs: Publishers.Fail<Output, Failure>, rhs: Publishers.Fail<Output, Failure>) -> Bool {
        return lhs.error == rhs.error
    }
}
