//
//  AnySubscriberTests.swift
//  CombineHarvesterTests
//
//  Created by Andreas Hartl on 14.06.19.
//

import XCTest
@testable import CombineHarvester

class AnySubscriberTests: XCTestCase {
    private enum TestError: Int, Error, RawRepresentable, Equatable {
        case error
    }

    private class TestSubscriber: Subscriber {
        typealias Input = Int
        typealias Failure = TestError
        var subscriptions = [Subscription]()
        var values = [Input]()
        var completions = [Subscribers.Completion<Failure>]()

        let combineIdentifier = CombineIdentifier(self as AnyObject)

        func receive(subscription: Subscription) {
            self.subscriptions.append(subscription)
        }

        func receive(_ input: Input) -> Subscribers.Demand {
            self.values.append(input)
            return .max(input)
        }

        func receive(completion: Subscribers.Completion<TestError>) {
            self.completions.append(completion)
        }
    }

    func testDelegation() {
        var subscriber = TestSubscriber()
        var underTest = AnySubscriber(subscriber)

        XCTAssertEqual(underTest.combineIdentifier, subscriber.combineIdentifier)

        underTest.receive(subscription: Subscriptions.empty)
        XCTAssertEqual(underTest.receive(0), .max(0))
        XCTAssertEqual(underTest.receive(10), .max(10))
        underTest.receive(completion: .finished)
        underTest.receive(completion: .failure(.error))

        XCTAssert(subscriber.subscriptions.map { $0 as! AnyHashable } == [Subscriptions.empty as! AnyHashable])
        XCTAssertEqual(subscriber.values, [0, 10])
        XCTAssertEqual(subscriber.completions, [Subscribers.Completion<TestError>.finished, Subscribers.Completion<TestError>.failure(.error)])

        subscriber = TestSubscriber()
        underTest = AnySubscriber(receiveSubscription: subscriber.receive(subscription:), receiveValue: subscriber.receive, receiveCompletion: subscriber.receive(completion:))

        XCTAssertNotEqual(underTest.combineIdentifier, subscriber.combineIdentifier)

        underTest.receive(subscription: Subscriptions.empty)
        XCTAssertEqual(underTest.receive(0), .max(0))
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
