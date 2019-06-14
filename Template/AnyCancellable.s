import RxSwift

/// A type-erasing cancellable object that executes a provided closure when canceled.
///
/// Subscriber implementations can use this type to provide a “cancellation token” that makes it possible for a caller to cancel a publisher, but not to use the `Subscription` object to request items.
public final class AnyCancellable: Cancellable {
    
    private let disposable: Disposable
    
    /// Initializes the cancellable object with the given cancel-time closure.
    ///
    /// - Parameter cancel: A closure that the `cancel()` method executes.
    public init(_ cancelClosure: @escaping () -> Void) {
        self.disposable = Disposables.create(with: cancelClosure)
    }

    public init<C>(_ cancellable: C) where C: Cancellable {
        self.disposable = Disposables.create(with: cancellable.cancel)
    }

    /// Cancel the activity.
    public final func cancel() {
        disposable.dispose()
    }
}

extension AnyCancellable {
    public convenience init(_ disposable: Disposable) {
        self.init(disposable.dispose)
    }
}
