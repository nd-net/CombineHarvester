//
//  SchedulerTests.swift
//  CombineHarvesterTests
//
//  Created by Andreas Hartl on 14.06.19.
//

import XCTest
@testable import CombineHarvester

private struct Nanoseconds {
    let value: Int
}

extension Nanoseconds: SignedNumeric, Comparable {
    static func -= (lhs: inout Nanoseconds, rhs: Nanoseconds) {
        lhs = lhs - rhs
    }

    static func - (lhs: Nanoseconds, rhs: Nanoseconds) -> Nanoseconds {
        return Nanoseconds(value: lhs.value - rhs.value)
    }

    init(integerLiteral value: Int) {
        self.init(value: value)
    }

    init?<T>(exactly source: T) where T: BinaryInteger {
        guard let value = Int(exactly: source) else {
            return nil
        }
        self.init(value: value)
    }

    var magnitude: Int.Magnitude {
        return self.value.magnitude
    }

    static func * (lhs: Nanoseconds, rhs: Nanoseconds) -> Nanoseconds {
        return Nanoseconds(value: lhs.value * rhs.value)
    }

    static func *= (lhs: inout Nanoseconds, rhs: Nanoseconds) {
        lhs = lhs * rhs
    }

    static func += (lhs: inout Nanoseconds, rhs: Nanoseconds) {
        lhs = lhs + rhs
    }

    static func + (lhs: Nanoseconds, rhs: Nanoseconds) -> Nanoseconds {
        return Nanoseconds(value: lhs.value + rhs.value)
    }

    static func == (lhs: Nanoseconds, rhs: Nanoseconds) -> Bool {
        return lhs.value == rhs.value
    }
}

extension Nanoseconds: Strideable {
    func distance(to other: Nanoseconds) -> Nanoseconds {
        return other - self
    }

    func advanced(by n: Nanoseconds) -> Nanoseconds {
        return self + n
    }
}

extension Nanoseconds: SchedulerTimeIntervalConvertible {
    static func seconds(_ s: Int) -> Nanoseconds {
        return Nanoseconds(value: s * 1_000_000_000)
    }

    static func seconds(_ s: Double) -> Nanoseconds {
        return Nanoseconds(value: Int(s * 1_000_000_000))
    }

    static func milliseconds(_ ms: Int) -> Nanoseconds {
        return Nanoseconds(value: ms * 1_000_000)
    }

    static func microseconds(_ us: Int) -> Nanoseconds {
        return Nanoseconds(value: us * 1000)
    }

    static func nanoseconds(_ ns: Int) -> Nanoseconds {
        return Nanoseconds(value: ns)
    }
}

class SchedulerTests: XCTestCase {
    private struct Call: Equatable {
        let after: Nanoseconds?
        let interval: Nanoseconds?
        let tolerance: Nanoseconds?
        let options: TestScheduler.SchedulerOptions?
    }

    private class TestScheduler: Scheduler {
        typealias SchedulerOptions = Int

        var call: Call?

        var now = Nanoseconds(value: 42)

        var minimumTolerance = Nanoseconds(value: 23)

        func schedule(after date: Nanoseconds, tolerance: Nanoseconds, options: SchedulerOptions?, _: @escaping () -> Void) {
            self.call = Call(after: date, interval: nil, tolerance: tolerance, options: options)
        }

        func schedule(after date: Nanoseconds, interval: Nanoseconds, tolerance: Nanoseconds, options: SchedulerOptions?, _: @escaping () -> Void) -> Cancellable {
            self.call = Call(after: date, interval: interval, tolerance: tolerance, options: options)
            return AnyCancellable {}
        }

        func schedule(options: SchedulerOptions?, _: @escaping () -> Void) {
            self.call = Call(after: nil, interval: nil, tolerance: nil, options: options)
        }
    }

    func testDefaultImplementations() {
        let underTest = TestScheduler()

        underTest.schedule(after: 10) {}
        XCTAssertEqual(underTest.call, Call(after: 10, interval: nil, tolerance: 23, options: nil))

        underTest.schedule {}
        XCTAssertEqual(underTest.call, Call(after: nil, interval: nil, tolerance: nil, options: nil))

        _ = underTest.schedule(after: 10, interval: 20, tolerance: 25) {}
        XCTAssertEqual(underTest.call, Call(after: 10, interval: 20, tolerance: 25, options: nil))

        _ = underTest.schedule(after: 10, interval: 20) {}
        XCTAssertEqual(underTest.call, Call(after: 10, interval: 20, tolerance: 23, options: nil))
    }
}
