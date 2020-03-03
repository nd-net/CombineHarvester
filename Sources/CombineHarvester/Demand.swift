extension Subscribers {
    /// A requested number of items, sent to a publisher from a subscriber via the subscription.
    ///
    /// - unlimited: A request for an unlimited number of items.
    /// - max: A request for a maximum number of items.
    public struct Demand: Comparable, Hashable, Codable, CustomStringConvertible {
        /// Returns the number of requested values, or nil if unlimited.
        public let max: Int?

        /// Requests as many values as the `Publisher` can produce.
        public static let unlimited = Subscribers.Demand(max: nil)

        /// A demand for no items.
        ///
        /// This is equivalent to `Demand.max(0)`.
        public static let none = Subscribers.Demand(max: 0)

        /// Limits the maximum number of values.
        /// The `Publisher` may send fewer than the requested number.
        /// Negative values will result in a `fatalError`.
        public static func max(_ value: Int) -> Subscribers.Demand {
            guard value >= 0 else {
                fatalError()
            }
            return Demand(max: value)
        }

        public var description: String {
            guard let max = self.max else {
                return "unlimited"
            }
            if max == 0 {
                return "none"
            } else {
                return "max(\(max))"
            }
        }

        /// When adding any value to .unlimited, the result is .unlimited.
        @inlinable public static func + (lhs: Subscribers.Demand, rhs: Subscribers.Demand) -> Subscribers.Demand {
            switch (rhs.max, lhs.max) {
            case (.none, _), (_, .none):
                return .unlimited
            case let (.some(l), .some(r)):
                return .max(l + r)
            }
        }

        /// When adding any value to .unlimited, the result is .unlimited.
        @inlinable public static func += (lhs: inout Subscribers.Demand, rhs: Subscribers.Demand) {
            lhs = lhs + rhs
        }

        /// When adding any value to .unlimited, the result is .unlimited.
        @inlinable public static func + (lhs: Subscribers.Demand, rhs: Int) -> Subscribers.Demand {
            return rhs >= 0 ? lhs + .max(rhs) : lhs - .max(-rhs)
        }

        /// When adding any value to .unlimited, the result is .unlimited.
        @inlinable public static func += (lhs: inout Subscribers.Demand, rhs: Int) {
            lhs = lhs + rhs
        }

        @inlinable public static func * (lhs: Subscribers.Demand, rhs: Int) -> Subscribers.Demand {
            if let value = lhs.max {
                return .max(value * rhs)
            } else if rhs > 0 {
                return .unlimited
            } else {
                return .none
            }
        }

        @inlinable public static func *= (lhs: inout Subscribers.Demand, rhs: Int) {
            lhs = lhs * rhs
        }

        /// When subtracting any value (including .unlimited) from .unlimited, the result is still .unlimited. Subtracting unlimited from any value (except unlimited) results in .max(0). A negative demand is not possible; any operation that would result in a negative value is clamped to .max(0).
        @inlinable public static func - (lhs: Subscribers.Demand, rhs: Subscribers.Demand) -> Subscribers.Demand {
            switch (lhs.max, rhs.max) {
            case (_, .none):
                return .none
            case (.none, _):
                return .unlimited
            case let (.some(l), .some(r)):
                let value = l - r
                return value > 0 ? .max(value) : .none
            }
        }

        /// When subtracting any value (including .unlimited) from .unlimited, the result is still .unlimited. Subtracting unlimited from any value (except unlimited) results in .max(0). A negative demand is not possible; any operation that would result in a negative value is clamped to .max(0).
        @inlinable public static func -= (lhs: inout Subscribers.Demand, rhs: Subscribers.Demand) {
            lhs = lhs - rhs
        }

        /// When subtracting any value from .unlimited, the result is still .unlimited. A negative demand is not possible; any operation that would result in a negative value is clamped to .max(0)
        @inlinable public static func - (lhs: Subscribers.Demand, rhs: Int) -> Subscribers.Demand {
            return rhs >= 0 ? lhs - .max(rhs) : lhs + .max(-rhs)
        }

        /// When subtracting any value from .unlimited, the result is still .unlimited. A negative demand is not possible; any operation that would result in a negative value is clamped to .max(0)
        @inlinable public static func -= (lhs: inout Subscribers.Demand, rhs: Int) {
            lhs = lhs - rhs
        }

        @inlinable public static func > (lhs: Subscribers.Demand, rhs: Int) -> Bool {
            return rhs >= 0 ? lhs > .max(rhs) : true
        }

        @inlinable public static func >= (lhs: Subscribers.Demand, rhs: Int) -> Bool {
            return rhs < 0 ? true : lhs >= .max(rhs)
        }

        @inlinable public static func > (lhs: Int, rhs: Subscribers.Demand) -> Bool {
            return lhs < 0 ? false : .max(lhs) > rhs
        }

        @inlinable public static func >= (lhs: Int, rhs: Subscribers.Demand) -> Bool {
            return lhs < 0 ? false : .max(lhs) >= rhs
        }

        @inlinable public static func < (lhs: Subscribers.Demand, rhs: Int) -> Bool {
            return rhs < 0 ? false : lhs < .max(rhs)
        }

        @inlinable public static func < (lhs: Int, rhs: Subscribers.Demand) -> Bool {
            return lhs < 0 ? true : .max(lhs) < rhs
        }

        @inlinable public static func <= (lhs: Subscribers.Demand, rhs: Int) -> Bool {
            return rhs < 0 ? false : lhs <= .max(rhs)
        }

        @inlinable public static func <= (lhs: Int, rhs: Subscribers.Demand) -> Bool {
            return lhs < 0 ? true : .max(lhs) <= rhs
        }

        /// If lhs is .unlimited, then the result is always false. If rhs is .unlimited then the result is always false. Otherwise, the two max values are compared.
        @inlinable public static func < (lhs: Subscribers.Demand, rhs: Subscribers.Demand) -> Bool {
            switch (lhs.max, rhs.max) {
            case (.some(_), .none):
                return true
            case (.none, _):
                return true
            case let (.some(l), .some(r)):
                return l < r
            }
        }

        /// If lhs is .unlimited and rhs is .unlimited then the result is true. Otherwise, the rules for < are followed.
        @inlinable public static func <= (lhs: Subscribers.Demand, rhs: Subscribers.Demand) -> Bool {
            return lhs == rhs || lhs < rhs
        }

        /// Returns a Boolean value that indicates whether the value of the first
        /// argument is greater than or equal to that of the second argument.
        ///
        /// - Parameters:
        ///   - lhs: A value to compare.
        ///   - rhs: Another value to compare.
        @inlinable public static func >= (lhs: Subscribers.Demand, rhs: Subscribers.Demand) -> Bool {
            return lhs == rhs || lhs > rhs
        }

        /// If rhs is .unlimited, then the result is always false. If lhs is .unlimited then the result is always false. Otherwise, the two max values are compared.
        @inlinable public static func > (lhs: Subscribers.Demand, rhs: Subscribers.Demand) -> Bool {
            return rhs < lhs
        }

        /// Returns `true` if `lhs` and `rhs` are equal. `.unlimited` is not equal to any integer.
        @inlinable public static func == (lhs: Subscribers.Demand, rhs: Int) -> Bool {
            return rhs < 0 ? false : lhs == .max(rhs)
        }

        /// Returns `true` if `lhs` and `rhs` are not equal. `.unlimited` is not equal to any integer.
        @inlinable public static func != (lhs: Subscribers.Demand, rhs: Int) -> Bool {
            return !(lhs == rhs)
        }

        /// Returns `true` if `lhs` and `rhs` are equal. `.unlimited` is not equal to any integer.
        @inlinable public static func == (lhs: Int, rhs: Subscribers.Demand) -> Bool {
            return lhs < 0 ? false : .max(lhs) == rhs
        }

        /// Returns `true` if `lhs` and `rhs` are not equal. `.unlimited` is not equal to any integer.
        @inlinable public static func != (lhs: Int, rhs: Subscribers.Demand) -> Bool {
            return !(lhs == rhs)
        }
    }
}
