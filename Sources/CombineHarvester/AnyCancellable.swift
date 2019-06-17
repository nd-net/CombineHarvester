/// A type-erasing cancellable object that executes a provided closure when canceled.
///
/// Subscriber implementations can use this type to provide a “cancellation token” that makes it possible for a caller to cancel a publisher, but not to use the `Subscription` object to request items.
public final class AnyCancellable: Cancellable {
    private var didCancel: Atomic<(() -> Void)?>

    /// Initializes the cancellable object with the given cancel-time closure.
    ///
    /// - Parameter cancel: A closure that the `cancel()` method executes.
    public init(_ cancelClosure: @escaping () -> Void) {
        self.didCancel = Atomic(value: cancelClosure)
    }

    public init<C>(_ cancellable: C) where C: Cancellable {
        self.didCancel = Atomic(value: cancellable.cancel)
    }

    /// Cancel the activity.
    public final func cancel() {
        self.didCancel.swap(nil)?()
    }

    /// AnyCancellable cancels on deinit
    deinit {
        self.cancel()
    }
}
