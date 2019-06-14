
extension Subscribers {
    /// A simple subscriber that requests an unlimited number of values upon subscription.
    public final class Sink<Upstream>: Subscriber, Cancellable, CustomStringConvertible where Upstream: Publisher {
        /// The kind of values this subscriber receives.
        public typealias Input = Upstream.Output
        
        /// The kind of errors this subscriber might receive.
        ///
        /// Use `Never` if this `Subscriber` cannot receive errors.
        public typealias Failure = Upstream.Failure
        
        /// The closure to execute on receipt of a value.
        public final let receiveValue: (Upstream.Output) -> Void
        
        /// The closure to execute on completion.
        public final let receiveCompletion: (Subscribers.Completion<Upstream.Failure>) -> Void
        
        public final var description: String { get { notImplemented() } }
        
        private var cancellables = [Cancellable]()
        
        /// Initializes a sink with the provided closures.
        ///
        /// - Parameters:
        ///   - receiveValue: The closure to execute on receipt of a value. If `nil`, the sink uses an empty closure.
        ///   - receiveCompletion: The closure to execute on completion. If `nil`, the sink uses an empty closure.
        public init(receiveCompletion: ((Subscribers.Completion<Subscribers.Sink<Upstream>.Failure>) -> Void)? = nil, receiveValue: @escaping ((Subscribers.Sink<Upstream>.Input) -> Void)) {
            self.receiveCompletion=receiveCompletion ?? {_ in }
            self.receiveValue=receiveValue
        }
        
        /// Tells the subscriber that it has successfully subscribed to the publisher and may request items.
        ///
        /// Use the received `Subscription` to request items from the publisher.
        /// - Parameter subscription: A subscription that represents the connection between publisher and subscriber.
        public final func receive(subscription: Subscription) {
            subscription.request(.unlimited)
            self.cancellables.append( subscription)
        }
        
        /// Tells the subscriber that the publisher has produced an element.
        ///
        /// - Parameter input: The published element.
        /// - Returns: A `Demand` instance indicating how many more elements the subcriber expects to receive.
        public final func receive(_ value: Subscribers.Sink<Upstream>.Input) -> Subscribers.Demand {
            self.receiveValue(value)
            return .unlimited
        }
        
        /// Tells the subscriber that the publisher has completed publishing, either normally or with an error.
        ///
        /// - Parameter completion: A `Completion` case indicating whether publishing completed normally or with an error.
        public final func receive(completion: Subscribers.Completion<Subscribers.Sink<Upstream>.Failure>) {
            self.receiveCompletion( completion)
        }
        
        /// Cancel the activity.
        public final func cancel() {
            for cancellable in self.cancellables {
                cancellable.cancel()
            }
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
        self.receive(subscriber: sink)
        return sink
    }
}
