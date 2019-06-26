import Foundation

extension CountableRange where Bound == Int {
    /// Used to convert an unbounded RangeExpression to a ClosedRange
    private struct Infinity: Swift.Collection {
        subscript(_: Bound) -> Void {
            fatalError()
        }

        var startIndex: Bound {
            return 0
        }

        var endIndex: Bound {
            return Bound.max
        }

        func index(after i: Bound) -> Bound {
            return i + 1
        }
    }

    /// Creates an instance using a given range expression.
    ///
    /// The range expression is truncated between 0 and Int.max if it does specify bounds or bounds less than 0.
    /// - Parameter uncheckedRange: The range expression for which the CountableRange should be generated.
    /// - Returns: A CountableRange that matches the range expression.
    init<R: RangeExpression>(uncheckedRange range: R) where R.Bound == CountableRange.Bound {
        self = range.relative(to: Infinity())
    }
}
