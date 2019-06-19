//
//  AnySubscriberTests.swift
//  CombineHarvesterTests
//
//  Created by Andreas Hartl on 14.06.19.
//

import XCTest
@testable import CombineHarvester

class AnySubscriberTests: XCTestCase {
    func testDelegation() {
        var subscriber = TestSubscriber<Int, TestError>()
        var underTest = AnySubscriber(subscriber)

        XCTAssertEqual(underTest.combineIdentifier, subscriber.combineIdentifier)

        underTest.receive(subscription: Subscriptions.empty)
        subscriber.receiveResult = .max(0)
        XCTAssertEqual(underTest.receive(0), .max(0))
        subscriber.receiveResult = .max(10)
        XCTAssertEqual(underTest.receive(10), .max(10))
        underTest.receive(completion: .finished)
        underTest.receive(completion: .failure(.error))

        XCTAssert(subscriber.subscriptions.map { $0 as! AnyHashable } == [Subscriptions.empty as! AnyHashable])
        XCTAssertEqual(subscriber.values, [0, 10])
        XCTAssertEqual(subscriber.completions, [Subscribers.Completion<TestError>.finished, Subscribers.Completion<TestError>.failure(.error)])

        subscriber = TestSubscriber<Int, TestError>()
        underTest = AnySubscriber(receiveSubscription: subscriber.receive(subscription:), receiveValue: subscriber.receive, receiveCompletion: subscriber.receive(completion:))

        XCTAssertNotEqual(underTest.combineIdentifier, subscriber.combineIdentifier)

        underTest.receive(subscription: Subscriptions.empty)
        subscriber.receiveResult = .max(0)
        XCTAssertEqual(underTest.receive(0), .max(0))
        subscriber.receiveResult = .max(10)
        XCTAssertEqual(underTest.receive(10), .max(10))
        underTest.receive(completion: .finished)
        underTest.receive(completion: .failure(.error))

        XCTAssert(subscriber.subscriptions.map { $0 as! AnyHashable } == [Subscriptions.empty as! AnyHashable])
        XCTAssertEqual(subscriber.values, [0, 10])
        XCTAssertEqual(subscriber.completions, [Subscribers.Completion<TestError>.finished, Subscribers.Completion<TestError>.failure(.error)])

        underTest = AnySubscriber(receiveSubscription: nil, receiveValue: nil, receiveCompletion: nil)
        XCTAssertNotEqual(underTest.combineIdentifier, subscriber.combineIdentifier)

        underTest.receive(subscription: Subscriptions.empty)
        XCTAssertEqual(underTest.receive(0), .unlimited)
        XCTAssertEqual(underTest.receive(10), .unlimited)
        underTest.receive(completion: .finished)
        underTest.receive(completion: .failure(.error))
    }
}
