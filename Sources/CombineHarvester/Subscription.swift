/// A protocol representing the connection of a subscriber to a publisher.
///
/// Subcriptions are class constrained because a `Subscription` has identity -
/// defined by the moment in time a particular subscriber attached to a publisher.
/// Canceling a `Subscription` must be thread-safe.
///
/// You can only cancel a `Subscription` once.
///
/// Canceling a subscription frees up any resources previously allocated by attaching the `Subscriber`.
public protocol Subscription: AnyObject, Cancellable, CustomCombineIdentifierConvertible {
    /// Tells a publisher that it may send more values to the subscriber.
    func request(_ demand: Subscribers.Demand)
}

public enum Subscriptions {
}

extension Subscriptions {
    private class EmptySubscription: Subscription, Hashable {
        func request(_: Subscribers.Demand) {
        }

        func cancel() {
        }

        func hash(into hasher: inout Hasher) {
            return hasher.combine(self.combineIdentifier)
        }

        static func == (lhs: Subscriptions.EmptySubscription, rhs: Subscriptions.EmptySubscription) -> Bool {
            return lhs.combineIdentifier == rhs.combineIdentifier
        }
    }

    /// Returns the 'empty' subscription.
    ///
    /// Use the empty subscription when you need a `Subscription` that ignores requests and cancellation.
    public static var empty: Subscription = EmptySubscription()
}
