//
//  DemandTests.swift
//  CombineHarvesterTests
//
//  Created by Andreas Hartl on 14.06.19.
//

import XCTest
@testable import CombineHarvester

class DemandTests: XCTestCase {
    typealias Demand = Subscribers.Demand

    func testAdd() {
        let demandPlusDemand: [(Demand, Demand, Demand)] = [
            // none + some
            (.none, .none, .none),
            (.none, .max(1), .max(1)),
            (.none, .max(-1), .max(-1)),
            (.none, .unlimited, .unlimited),

            // max(1) + some
            (.max(1), .none, .max(1)),
            (.max(1), .max(1), .max(2)),
            (.max(1), .max(-1), .none),
            (.max(1), .unlimited, .unlimited),

            // max(-1) + some
            (.max(-1), .none, .max(-1)),
            (.max(-1), .max(1), .max(0)),
            (.max(-1), .max(-1), .max(-2)),
            (.max(-1), .unlimited, .unlimited),

            // unlimited + some
            (.unlimited, .none, .unlimited),
            (.unlimited, .max(1), .unlimited),
            (.unlimited, .max(-1), .unlimited),
            (.unlimited, .unlimited, .unlimited),
        ]
        let demandPlusInt: [(Demand, Int, Demand)] = [
            // none + some
            (.none, 0, .none),
            (.none, 1, .max(1)),
            (.none, -1, .max(-1)),

            // max(1) + some
            (.max(1), 0, .max(1)),
            (.max(1), 1, .max(2)),
            (.max(1), -1, .max(0)),

            // max(-1) + some
            (.max(-1), 0, .max(-1)),
            (.max(-1), 1, .max(0)),
            (.max(-1), -1, .max(-2)),

            // unlimited + some
            (.unlimited, 0, .unlimited),
            (.unlimited, 1, .unlimited),
            (.unlimited, -1, .unlimited),
        ]

        for (lhs, rhs, expected) in demandPlusDemand {
            XCTAssertEqual(lhs + rhs, expected, "\(lhs) + \(rhs) == \(expected)")

            var element = lhs
            element += rhs
            XCTAssertEqual(element, expected, "\(lhs) += \(rhs) == \(expected)")
        }

        for (lhs, rhs, expected) in demandPlusInt {
            XCTAssertEqual(lhs + rhs, expected, "\(lhs) + \(rhs) == \(expected)")

            var element = lhs
            element += rhs
            XCTAssertEqual(element, expected, "\(lhs) += \(rhs) == \(expected)")
        }
    }

    func testSubtract() {
        let demandMinusDemand: [(Demand, Demand, Demand)] = [
            // none - some
            (.none, .none, .none),
            (.none, .max(1), .max(-1)),
            (.none, .max(-1), .max(1)),
            (.none, .unlimited, .none),

            // max(1) - some
            (.max(1), .none, .max(1)),
            (.max(1), .max(1), .max(0)),
            (.max(1), .max(-1), .max(2)),
            (.max(1), .unlimited, .none),

            // max(-1) - some
            (.max(-1), .none, .max(-1)),
            (.max(-1), .max(1), .max(-2)),
            (.max(-1), .max(-1), .max(0)),
            (.max(-1), .unlimited, .none),

            // unlimited - some
            (.unlimited, .none, .unlimited),
            (.unlimited, .max(1), .unlimited),
            (.unlimited, .max(-1), .unlimited),
            (.unlimited, .unlimited, .none),
        ]
        let demandMinusInt: [(Demand, Int, Demand)] = [
            // none - some
            (.none, 0, .none),
            (.none, 1, .max(-1)),
            (.none, -1, .max(1)),

            // max(1) - some
            (.max(1), 0, .max(1)),
            (.max(1), 1, .max(0)),
            (.max(1), -1, .max(2)),

            // max(-1) - some
            (.max(-1), 0, .max(-1)),
            (.max(-1), 1, .max(-2)),
            (.max(-1), -1, .max(0)),

            // unlimited - some
            (.unlimited, 0, .unlimited),
            (.unlimited, 1, .unlimited),
            (.unlimited, -1, .unlimited),
        ]

        for (lhs, rhs, expected) in demandMinusDemand {
            XCTAssertEqual(lhs - rhs, expected, "\(lhs) - \(rhs) == \(expected)")

            var element = lhs
            element -= rhs
            XCTAssertEqual(element, expected, "\(lhs) -= \(rhs) == \(expected)")
        }

        for (lhs, rhs, expected) in demandMinusInt {
            XCTAssertEqual(lhs - rhs, expected, "\(lhs) - \(rhs) == \(expected)")

            var element = lhs
            element -= rhs
            XCTAssertEqual(element, expected, "\(lhs) -= \(rhs) == \(expected)")
        }
    }

    func testMultiply() {
        let demandTimesInt: [(Demand, Int, Demand)] = [
            // none * some
            (.none, 0, .none),
            (.none, 1, .none),
            (.none, 2, .none),
            (.none, -1, .none),

            // max(1) , some
            (.max(1), 0, .none),
            (.max(1), 1, .max(1)),
            (.max(1), 2, .max(2)),
            (.max(1), -1, .max(-1)),

            // max(-1) , some
            (.max(-1), 0, .max(0)),
            (.max(-1), 1, .max(-1)),
            (.max(-1), 2, .max(-2)),
            (.max(-1), -1, .max(1)),

            // unlimited , some
            (.unlimited, 0, .none),
            (.unlimited, 1, .unlimited),
            (.unlimited, 2, .unlimited),
            (.unlimited, -1, .none),
        ]

        for (lhs, rhs, expected) in demandTimesInt {
            XCTAssertEqual(lhs * rhs, expected, "\(lhs) * \(rhs) == \(expected)")

            var element = lhs
            element *= rhs
            XCTAssertEqual(element, expected, "\(lhs) *= \(rhs) == \(expected)")
        }
    }

    func testEquatable() {
        for number in -10...10 {
            XCTAssertTrue(Demand.max(number) == Demand.max(number))
            XCTAssertFalse(Demand.max(number) == Demand.unlimited)
            XCTAssertFalse(Demand.unlimited == Demand.max(number))

            XCTAssertTrue(number == Demand.max(number))
            XCTAssertTrue(Demand.max(number) == number)
            XCTAssertFalse(number != Demand.max(number))
            XCTAssertFalse(Demand.max(number) != number)

            XCTAssertFalse(number == Demand.unlimited)
            XCTAssertFalse(Demand.unlimited == number)
            XCTAssertTrue(number != Demand.unlimited)
            XCTAssertTrue(Demand.unlimited != number)
        }
        XCTAssertTrue(Demand.unlimited == Demand.unlimited)
    }

    func testComparable() {
        let demandLessThan: [(Demand, Demand)] = [
            (.max(-1), .none),
            (.none, .max(1)),
            (.none, .unlimited),
            (.max(1), .max(2)),
            (.max(1), .unlimited),
        ]
        let intLessThan: [(Int, Demand)] = [
            (-1, .none),
            (0, .max(1)),
            (0, .unlimited),
            (1, .max(2)),
            (1, .unlimited),
        ]

        for (lhs, rhs) in demandLessThan {
            XCTAssert(lhs < rhs, "\(lhs)  < \(rhs)")
            XCTAssert(lhs <= rhs, "\(lhs) <= \(rhs)")
            XCTAssert(lhs <= lhs, "\(lhs) <= \(lhs)")
            XCTAssert(rhs <= rhs, "\(rhs) <= \(rhs)")

            XCTAssert(rhs > lhs, "\(rhs)  > \(lhs)")
            XCTAssert(rhs >= lhs, "\(rhs) >= \(lhs)")
            XCTAssert(rhs >= rhs, "\(rhs) >= \(rhs)")
            XCTAssert(lhs >= lhs, "\(lhs) >= \(lhs)")
        }
        for (lhs, rhs) in intLessThan {
            XCTAssert(lhs < rhs, "\(lhs)  < \(rhs)")
            XCTAssert(lhs <= rhs, "\(lhs) <= \(rhs)")
            XCTAssert(lhs <= lhs, "\(lhs) <= \(lhs)")
            XCTAssert(rhs <= rhs, "\(rhs) <= \(rhs)")

            XCTAssert(rhs > lhs, "\(rhs)  > \(lhs)")
            XCTAssert(rhs >= lhs, "\(rhs) >= \(lhs)")
            XCTAssert(rhs >= rhs, "\(rhs) >= \(rhs)")
            XCTAssert(lhs >= lhs, "\(lhs) >= \(lhs)")
        }
    }

    func testMax() {
        for number in -10...10 {
            XCTAssertEqual(Demand.max(number).max, number)
        }
        XCTAssertEqual(Demand.none.max, 0)
        XCTAssertEqual(Demand.unlimited.max, nil)
    }
}
