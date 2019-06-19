//
//  IteratingSubscriptionTests.swift
//  CombineHarvesterTests
//
//  Created by Andreas Hartl on 19.06.19.
//

import XCTest
@testable import CombineHarvester

class IteratingSubscriptionTests: XCTestCase {
    lazy var lorem = "Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet. Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet. Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet."
        .split(separator: " ")
        .map { String($0) }

    func testEmptyArray() {
        let results: [Result<String, Never>] = []
        let subscriber = TestSubscriber<String, Never>()
        let subscription = IteratingSubscription(iterator: results.makeIterator(), subscriber: subscriber)

        // nothing there yet
        XCTAssertEqual(subscriber.values, [])
        XCTAssertEqual(subscriber.completions, [])

        // nothing requested: still nothing there
        subscription.request(.none)
        XCTAssertEqual(subscriber.values, [])
        XCTAssertEqual(subscriber.completions, [])

        // request 1: the subscription completes
        subscription.request(.max(1))
        XCTAssertEqual(subscriber.values, [])
        XCTAssertEqual(subscriber.completions, [.finished])

        _ = subscription
    }

    func testCancelEmptyArray() {
        let results: [Result<String, Never>] = []
        let subscriber = TestSubscriber<String, Never>()
        let subscription = IteratingSubscription(iterator: results.makeIterator(), subscriber: subscriber)

        subscription.cancel()

        subscription.request(.unlimited)
        XCTAssertEqual(subscriber.values, [])
        XCTAssertEqual(subscriber.completions, [])
    }

    func testNonEmptyArrayWithBackpressure() {
        let results: [Result<String, Never>] = self.lorem.map { .success($0) }

        let subscriber = TestSubscriber<String, Never>()
        subscriber.receiveResult = .none

        let subscription = IteratingSubscription(iterator: results.makeIterator(), subscriber: subscriber)

        // nothing there yet
        XCTAssertEqual(subscriber.values, [])
        XCTAssertEqual(subscriber.completions, [])

        // nothing requested: still nothing there
        subscription.request(.none)
        XCTAssertEqual(subscriber.values, [])
        XCTAssertEqual(subscriber.completions, [])

        // request 1: the subscription only gets one element
        subscription.request(.max(1))
        XCTAssertEqual(subscriber.values, Array(self.lorem[..<1]))
        XCTAssertEqual(subscriber.completions, [])

        subscription.request(.max(2))
        XCTAssertEqual(subscriber.values, Array(self.lorem[..<3]))
        XCTAssertEqual(subscriber.completions, [])

        subscriber.receiveResult = .max(1)

        // request 2: nothing requested, so nothing to do
        subscription.request(.none)
        XCTAssertEqual(subscriber.values, Array(self.lorem[..<3]))
        XCTAssertEqual(subscriber.completions, [])

        // request 2: request 1, but demand more upon receiving it
        subscription.request(.max(1))
        XCTAssertEqual(subscriber.values, self.lorem)
        XCTAssertEqual(subscriber.completions, [.finished])

        _ = subscription
    }

    func testNonEmptyArrayWithoutBackpressure() {
        let results: [Result<String, Never>] = self.lorem.map { .success($0) }

        let subscriber = TestSubscriber<String, Never>()
        subscriber.receiveResult = .none

        let subscription = IteratingSubscription(iterator: results.makeIterator(), subscriber: subscriber)

        // request unlimited data
        subscription.request(.unlimited)
        XCTAssertEqual(subscriber.values, self.lorem)
        XCTAssertEqual(subscriber.completions, [.finished])

        _ = subscription
    }

    func testCancelNonEmptyArray() {
        let results: [Result<String, Never>] = self.lorem.map { .success($0) }

        let subscriber = TestSubscriber<String, Never>()

        let subscription = IteratingSubscription(iterator: results.makeIterator(), subscriber: subscriber)
        subscription.cancel()

        // request data after cancellation
        subscription.request(.unlimited)
        XCTAssertEqual(subscriber.values, [])
        XCTAssertEqual(subscriber.completions, [])

        _ = subscription
    }

    func testIteratorWithError() {
        let results: [Result<String, TestError>] = self.lorem.map { $0 == "dolor" ? .failure(.error) : .success($0) }

        let subscriber = TestSubscriber<String, TestError>()
        subscriber.receiveResult = .none

        let subscription = IteratingSubscription(iterator: results.makeIterator(), subscriber: subscriber)

        // nothing requested: still nothing there
        subscription.request(.none)
        XCTAssertEqual(subscriber.values, [])
        XCTAssertEqual(subscriber.completions, [])

        // request 1: the subscription only gets one element
        subscription.request(.max(1))
        XCTAssertEqual(subscriber.values, Array(self.lorem[..<1]))
        XCTAssertEqual(subscriber.completions, [])

        // request 2: subscription gets everything until the error
        subscription.request(.max(10))
        XCTAssertEqual(subscriber.values, Array(self.lorem[..<2]))
        XCTAssertEqual(subscriber.completions, [.failure(.error)])
    }
}
