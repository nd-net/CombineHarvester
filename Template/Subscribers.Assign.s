
extension Subscribers {
    final public class Assign<Root, Input> : Subscriber, Cancellable, CustomStringConvertible, CustomReflectable, CustomPlaygroundDisplayConvertible {
        /// The kind of errors this subscriber might receive.
        ///
        /// Use `Never` if this `Subscriber` cannot receive errors.
        public typealias Failure = Never
        
        public final var object: Root? { get { notImplemented() } }
        
        public final let keyPath: ReferenceWritableKeyPath<Root, Input>
        
        /// A textual representation of this instance.
        ///
        /// Calling this property directly is discouraged. Instead, convert an
        /// instance of any type to a string by using the `String(describing:)`
        /// initializer. This initializer works with any type, and uses the custom
        /// `description` property for types that conform to
        /// `CustomStringConvertible`:
        ///
        ///     struct Point: CustomStringConvertible {
        ///         let x: Int, y: Int
        ///
        ///         var description: String {
        ///             return "(\(x), \(y))"
        ///         }
        ///     }
        ///
        ///     let p = Point(x: 21, y: 30)
        ///     let s = String(describing: p)
        ///     print(s)
        ///     // Prints "(21, 30)"
        ///
        /// The conversion of `p` to a string in the assignment to `s` uses the
        /// `Point` type's `description` property.
        public final var description: String { get { notImplemented() } }
        
        /// The custom mirror for this instance.
        ///
        /// If this type has value semantics, the mirror should be unaffected by
        /// subsequent mutations of the instance.
        public final var customMirror: Mirror { get { notImplemented() } }
        
        /// A custom playground description for this instance.
        public final var playgroundDescription: Any { get { notImplemented() } }
        
        public init(object: Root, keyPath: ReferenceWritableKeyPath<Root, Input>) { notImplemented() }
        
        /// Tells the subscriber that it has successfully subscribed to the publisher and may request items.
        ///
        /// Use the received `Subscription` to request items from the publisher.
        /// - Parameter subscription: A subscription that represents the connection between publisher and subscriber.
        public final func receive(subscription: Subscription) { notImplemented() }
        
        /// Tells the subscriber that the publisher has produced an element.
        ///
        /// - Parameter input: The published element.
        /// - Returns: A `Demand` instance indicating how many more elements the subcriber expects to receive.
        public final func receive(_ value: Input) -> Subscribers.Demand { notImplemented() }
        
        /// Tells the subscriber that the publisher has completed publishing, either normally or with an error.
        ///
        /// - Parameter completion: A `Completion` case indicating whether publishing completed normally or with an error.
        public final func receive(completion: Subscribers.Completion<Never>) { notImplemented() }
        
        /// Cancel the activity.
        public final func cancel() { notImplemented() }
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
