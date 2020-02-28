/// A type-erasing cancellable object that executes a provided closure when canceled.
///
/// Subscriber implementations can use this type to provide a “cancellation token” that makes it possible for a caller to cancel a publisher, but not to use the `Subscription` object to request items.
/// An AnyCancellable instance automatically calls `cancel()` when deinitialized.
public final class AnyCancellable: Cancellable, Hashable {
    private let identifier = CombineIdentifier()
    private var cancelClosure: Atomic<(() -> Void)?>

    /// Initializes the cancellable object with the given cancel-time closure.
    ///
    /// - Parameter cancel: A closure that the `cancel()` method executes.
    public init(_ cancel: @escaping () -> Void) {
        self.cancelClosure = Atomic(value: cancel)
    }

    public init<C: Cancellable>(_ canceller: C) {
        self.cancelClosure = Atomic(value: canceller.cancel)
    }

    /// Cancel the activity.
    public final func cancel() {
        self.cancelClosure.swap(nil)?()
    }

    /// AnyCancellable cancels on deinit
    deinit {
        self.cancel()
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.identifier)
    }

    public static func == (lhs: AnyCancellable, rhs: AnyCancellable) -> Bool {
        return lhs.identifier == rhs.identifier
    }
}

extension AnyCancellable {
    /// Stores this AnyCancellable in the specified collection.
    /// Parameters:
    ///    - collection: The collection to store this AnyCancellable.
    public final func store<C: RangeReplaceableCollection>(in collection: inout C) where C.Element == AnyCancellable {
        collection.append(self)
    }

    /// Stores this AnyCancellable in the specified set.
    /// Parameters:
    ///    - collection: The set to store this AnyCancellable.
    public final func store(in set: inout Set<AnyCancellable>) {
        set.insert(self)
    }
}
