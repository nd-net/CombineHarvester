import RxSwift
/// A protocol that declares a type that can receive input from a publisher.

public protocol Subscriber: CustomCombineIdentifierConvertible {
    /// The kind of values this subscriber receives.
    associatedtype Input

    /// The kind of errors this subscriber might receive.
    ///
    /// Use `Never` if this `Subscriber` cannot receive errors.
    associatedtype Failure: Error

    /// Tells the subscriber that it has successfully subscribed to the publisher and may request items.
    ///
    /// Use the received `Subscription` to request items from the publisher.
    /// - Parameter subscription: A subscription that represents the connection between publisher and subscriber.
    func receive(subscription: Subscription)

    /// Tells the subscriber that the publisher has produced an element.
    ///
    /// - Parameter input: The published element.
    /// - Returns: A `Demand` instance indicating how many more elements the subcriber expects to receive.
    func receive(_ input: Self.Input) -> Subscribers.Demand

    /// Tells the subscriber that the publisher has completed publishing, either normally or with an error.
    ///
    /// - Parameter completion: A `Completion` case indicating whether publishing completed normally or with an error.
    func receive(completion: Subscribers.Completion<Self.Failure>)
}


/// A namespace for types related to the `Subscriber` protocol.

public enum Subscribers {
}

extension Subscribers {
    /// A signal that a publisher doesn’t produce additional elements, either due to normal completion or an error.
    ///
    /// - finished: The publisher finished normally.
    /// - failure: The publisher stopped publishing due to the indicated error.
    public enum Completion<Failure> where Failure: Error {
        case finished
        
        case failure(Failure)
    }
}

extension Subscribers {
    /// A requested number of items, sent to a publisher from a subscriber via the subscription.
    ///
    /// - unlimited: A request for an unlimited number of items.
    /// - max: A request for a maximum number of items.
    public enum Demand: Equatable, Comparable {
        /// Requests as many values as the `Publisher` can produce.
        case unlimited
        
        /// Limits the maximum number of values.
        /// The `Publisher` may send fewer than the requested number.
        /// Negative values will result in a `fatalError`.
        case max(Int)
        
        /// When adding any value to .unlimited, the result is .unlimited.
        public static func + (lhs: Subscribers.Demand, rhs: Subscribers.Demand) -> Subscribers.Demand {
            switch (rhs,lhs) {
        case let (.max(l), .max(r)):
            return .max(l+r)
        default:
            return .unlimited
            } }
        
        /// A demand for no items.
        ///
        /// This is equivalent to `Demand.max(0)`.
        public static var none: Subscribers.Demand {
            return .max(0) }
        
        /// When adding any value to .unlimited, the result is .unlimited.
        public static func += (lhs: inout Subscribers.Demand, rhs: Subscribers.Demand) {
            lhs = lhs + rhs }
        
        /// When adding any value to .unlimited, the result is .unlimited.
        public static func + (lhs: Subscribers.Demand, rhs: Int) -> Subscribers.Demand {
            return lhs + .max(rhs) }
        
        /// When adding any value to .unlimited, the result is .unlimited.
        public static func += (lhs: inout Subscribers.Demand, rhs: Int) {
            lhs = lhs + rhs }
        
        public static func * (lhs: Subscribers.Demand, rhs: Int) -> Subscribers.Demand {
            guard case let .max(value) = lhs else {
                return .unlimited
            }
            return .max(value * rhs)
        }
        
        public static func *= (lhs: inout Subscribers.Demand, rhs: Int) {
        lhs=lhs*rhs}
        
        /// When subtracting any value (including .unlimited) from .unlimited, the result is still .unlimited. Subtracting unlimited from any value (except unlimited) results in .max(0). A negative demand is possible, but be aware that it is not usable when requesting values in a subscription.
        public static func - (lhs: Subscribers.Demand, rhs: Subscribers.Demand) -> Subscribers.Demand {
            switch (lhs, rhs) {
            case (.unlimited, _):
                return .unlimited
            case (_,.unlimited):
                return .none
            case let (.max(l), .max(r)):
                return l > r ? .max(l-r) : .none
            }
        }
        
        /// When subtracting any value (including .unlimited) from .unlimited, the result is still .unlimited. Subtracting unlimited from any value (except unlimited) results in .max(0). A negative demand is possible, but be aware that it is not usable when requesting values in a subscription.
        public static func -= (lhs: inout Subscribers.Demand, rhs: Subscribers.Demand) {
        lhs=lhs-rhs}
        
        /// When subtracting any value from .unlimited, the result is still .unlimited. A negative demand is possible, but be aware that it is not usable when requesting values in a subscription.
        public static func - (lhs: Subscribers.Demand, rhs: Int) -> Subscribers.Demand {
        return lhs - .max(rhs)}
        
        /// When subtracting any value from .unlimited, the result is still .unlimited. A negative demand is possible, but be aware that it is not usable when requesting values in a subscription.
        public static func -= (lhs: inout Subscribers.Demand, rhs: Int) {
              lhs=lhs-rhs}
        
        public static func > (lhs: Subscribers.Demand, rhs: Int) -> Bool {
            return lhs > .max(rhs)
        }
        
        public static func >= (lhs: Subscribers.Demand, rhs: Int) -> Bool {
        return lhs >= .max(rhs) }
        
        public static func > (lhs: Int, rhs: Subscribers.Demand) -> Bool {
            return .max(lhs) > rhs
}
        
        public static func >= (lhs: Int, rhs: Subscribers.Demand) -> Bool {
            return .max(lhs) >= rhs }

        
        public static func < (lhs: Subscribers.Demand, rhs: Int) -> Bool {
            return lhs < .max(rhs)
        }
        
        public static func < (lhs: Int, rhs: Subscribers.Demand) -> Bool {
        return .max(lhs) < rhs}
        
        public static func <= (lhs: Subscribers.Demand, rhs: Int) -> Bool {
            return lhs <= .max(rhs)}
        
        public static func <= (lhs: Int, rhs: Subscribers.Demand) -> Bool {
        return .max(lhs)<=rhs}
        
        
        /// If lhs is .unlimited, then the result is always false. If rhs is .unlimited then the result is always false. Otherwise, the two max values are compared.
        public static func < (lhs: Subscribers.Demand, rhs: Subscribers.Demand) -> Bool {
            switch (lhs, rhs) {
            case let (.max(l), .max(r)):
                return l < r
            default:
                return false
            }
        }
        
        /// If lhs is .unlimited and rhs is .unlimited then the result is true. Otherwise, the rules for < are followed.
        public static func <= (lhs: Subscribers.Demand, rhs: Subscribers.Demand) -> Bool {
            return lhs == rhs || lhs < rhs
        }
        
        /// Returns a Boolean value that indicates whether the value of the first
        /// argument is greater than or equal to that of the second argument.
        ///
        /// - Parameters:
        ///   - lhs: A value to compare.
        ///   - rhs: Another value to compare.
        public static func >= (lhs: Subscribers.Demand, rhs: Subscribers.Demand) -> Bool {
            return lhs == rhs || !(lhs < rhs)
        }
        
        /// If rhs is .unlimited, then the result is always false. If lhs is .unlimited then the result is always false. Otherwise, the two max values are compared.
        public static func > (lhs: Subscribers.Demand, rhs: Subscribers.Demand) -> Bool { notImplemented() }
        
        /// Returns `true` if `lhs` and `rhs` are equal. `.unlimited` is not equal to any integer.
        public static func == (lhs: Subscribers.Demand, rhs: Int) -> Bool {
            return lhs == .max(rhs)
        }
        
        /// Returns `true` if `lhs` and `rhs` are not equal. `.unlimited` is not equal to any integer.
        public static func != (lhs: Subscribers.Demand, rhs: Int) -> Bool {
        return lhs != .max(rhs)}
        
        /// Returns `true` if `lhs` and `rhs` are equal. `.unlimited` is not equal to any integer.
        public static func == (lhs: Int, rhs: Subscribers.Demand) -> Bool {
            return .max(lhs) == rhs
        }
        
        /// Returns `true` if `lhs` and `rhs` are not equal. `.unlimited` is not equal to any integer.
        public static func != (lhs: Int, rhs: Subscribers.Demand) -> Bool {
        return .max(lhs) != rhs}
        
        /// Returns the number of requested values, or nil if unlimited.
        public var max: Int? {
            if case let .max(value) = self {
                return value
            }
            return nil
        }
    }
}
