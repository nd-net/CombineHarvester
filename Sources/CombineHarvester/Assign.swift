
extension Subscribers {
    public final class Assign<Root, Input>: Subscriber, Cancellable /* , CustomStringConvertible, CustomReflectable, CustomPlaygroundDisplayConvertible */ {
        public typealias Failure = Never

        public private(set) final var object: Root?
        public final let keyPath: ReferenceWritableKeyPath<Root, Input>

        private var subscription: Subscription? {
            willSet {
                if newValue?.combineIdentifier != self.subscription?.combineIdentifier {
                    self.subscription?.cancel()
                }
            }
        }

        public init(object: Root, keyPath: ReferenceWritableKeyPath<Root, Input>) {
            self.object = object
            self.keyPath = keyPath
        }

        public final func receive(subscription: Subscription) {
            self.subscription = subscription
            subscription.request(.unlimited)
        }

        public final func receive(_ value: Input) -> Subscribers.Demand {
            guard let object = self.object else {
                return .unlimited
            }
            object[keyPath: self.keyPath] = value
            self.object = object
            return .unlimited
        }

        public final func receive(completion _: Subscribers.Completion<Never>) {
            self.cancel()
        }

        public final func cancel() {
            self.subscription = nil
            self.object = nil
        }

        deinit {
            self.cancel()
        }
    }
}

extension Publisher where Self.Failure == Never {
    /// Assigns the value of a KVO-compliant property from a publisher.
    ///
    /// - Parameters:
    ///   - keyPath: The key path of the property to assign.
    ///   - object: The object on which to assign the value.
    /// - Returns: A cancellable instance; used when you end KVO-based assignment of the key path’s value.
    public func assign<Root>(to keyPath: ReferenceWritableKeyPath<Root, Self.Output>, on object: Root) -> AnyCancellable {
        let subscriber = Subscribers.Assign(object: object, keyPath: keyPath)
        self.subscribe(subscriber)
        return AnyCancellable(subscriber)
    }
}
