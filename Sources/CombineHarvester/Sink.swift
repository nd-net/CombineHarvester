extension Subscribers {
    /// A simple subscriber that requests an unlimited number of values upon subscription.
    public final class Sink<Upstream>: Subscriber, Cancellable /* , CustomStringConvertible, CustomReflectable, CustomPlaygroundDisplayConvertible */ where Upstream: Publisher {
        public typealias Input = Upstream.Output

        public typealias Failure = Upstream.Failure

        /// The closure to execute on receipt of a value.
        public final let receiveValue: (Upstream.Output) -> Void
        /// The closure to execute on completion.
        public final let receiveCompletion: (Subscribers.Completion<Upstream.Failure>) -> Void

        public final var description: String {
            return "Sink(\(String(describing: self.subscription)))"
        }

        private var subscription: Subscription? {
            willSet {
                if newValue?.combineIdentifier != self.subscription?.combineIdentifier {
                    self.subscription?.cancel()
                }
            }
        }

        /// Initializes a sink with the provided closures.
        ///
        /// - Parameters:
        ///   - receiveValue: The closure to execute on receipt of a value. If `nil`, the sink uses an empty closure.
        ///   - receiveCompletion: The closure to execute on completion. If `nil`, the sink uses an empty closure.
        public init(receiveCompletion: ((Subscribers.Completion<Failure>) -> Void)? = nil, receiveValue: @escaping ((Input) -> Void)) {
            self.receiveCompletion = receiveCompletion ?? { _ in }
            self.receiveValue = receiveValue
        }

        public final func receive(subscription: Subscription) {
            self.subscription = subscription
            subscription.request(.unlimited)
        }

        public final func receive(_ value: Input) -> Subscribers.Demand {
            self.receiveValue(value)
            return .unlimited
        }

        public final func receive(completion: Subscribers.Completion<Failure>) {
            self.receiveCompletion(completion)
            self.cancel()
        }

        /// Cancel the activity.
        public final func cancel() {
            self.subscription = nil
        }

        deinit {
            cancel()
        }
    }
}

extension Publisher {
    /// Attaches a subscriber with closure-based behavior.
    ///
    /// This method creates the subscriber and immediately requests an unlimited number of values, prior to returning the subscriber.
    /// - parameter receiveValue: The closure to execute on receipt of a value. If `nil`, the sink uses an empty closure.
    /// - parameter receiveComplete: The closure to execute on completion. If `nil`, the sink uses an empty closure.
    /// - Returns: A subscriber that performs the provided closures upon receiving values or completion.
    public func sink(receiveCompletion: ((Subscribers.Completion<Self.Failure>) -> Void)? = nil, receiveValue: @escaping ((Self.Output) -> Void)) -> Subscribers.Sink<Self> {
        let sink = Subscribers.Sink<Self>(receiveCompletion: receiveCompletion, receiveValue: receiveValue)
        self.subscribe(sink)
        return sink
    }
}
