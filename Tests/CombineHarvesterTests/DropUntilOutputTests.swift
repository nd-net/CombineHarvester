//
//  DropUntilOutputTests.swift
//  CombineHarvesterTests
//
//  Created by Andreas Hartl on 27.06.19.
//

import XCTest
@testable import CombineHarvester

class DropUntilOutputTests: XCTestCase {
    func testDropBecauseOfOther() {
        var didCancelOther = false
        let publisher = PassthroughSubject<String, TestError>()
        let other = PassthroughSubject<String, TestError>()
        var receiver: TestSubject<String, TestError>

        receiver = TestSubject()

        let subscription = publisher.drop(untilOutputFrom: other.handleEvents(receiveCancel: { didCancelOther = true })).subscribe(receiver)

        XCTAssertEqual(receiver.values, [], "Nothing after subscription")
        XCTAssertEqual(receiver.completion, [], "Nothing after subscription")

        publisher.send("Hello")

        XCTAssertEqual(receiver.values, [], "Still nothing after publish, if the other didn't publish yet")
        XCTAssertEqual(receiver.completion, [], "Still nothing after publish, if the other didn't publish yet")

        other.send("X")

        XCTAssertTrue(didCancelOther, "After sending a value, the other must be cancelled")

        XCTAssertEqual(receiver.values, [], "If the other was received, but the publisher doesn't, then this still does not do anything")
        XCTAssertEqual(receiver.completion, [], "If the other was received, but the publisher doesn't, then this still does not do anything")

        publisher.send("World")

        XCTAssertEqual(receiver.values, ["World"], "Receiving now")
        XCTAssertEqual(receiver.completion, [], "Receiving now")

        publisher.send(completion: .finished)

        XCTAssertEqual(receiver.values, ["World"], "Receiving now")
        XCTAssertEqual(receiver.completion, [.finished], "Receiving now")

        _ = subscription
    }

    func testOtherFinishesWithoutData() {
        var didCancelUpstream = false

        let publisher = PassthroughSubject<String, TestError>()
        let other = PassthroughSubject<String, TestError>()
        var receiver: TestSubject<String, TestError>

        receiver = TestSubject()

        let subscription = publisher.handleEvents(receiveCancel: { didCancelUpstream = true }).drop(untilOutputFrom: other).subscribe(receiver)

        XCTAssertFalse(didCancelUpstream)
        XCTAssertEqual(receiver.values, [], "Nothing after subscription")
        XCTAssertEqual(receiver.completion, [], "Nothing after subscription")

        other.send(completion: .finished)

        publisher.send("Hello")

        XCTAssertTrue(didCancelUpstream)
        XCTAssertEqual(receiver.values, [], "Still nothing after publish, if the other finish publish yet")
        XCTAssertEqual(receiver.completion, [])

        _ = subscription
    }

    func testOtherErrorsWithoutData() {
        var didCancelUpstream = false

        let publisher = PassthroughSubject<String, TestError>()
        let other = PassthroughSubject<String, TestError>()
        var receiver: TestSubject<String, TestError>

        receiver = TestSubject()

        let subscription = publisher.handleEvents(receiveCancel: { didCancelUpstream = true }).drop(untilOutputFrom: other).subscribe(receiver)

        XCTAssertFalse(didCancelUpstream)
        XCTAssertEqual(receiver.values, [], "Nothing after subscription")
        XCTAssertEqual(receiver.completion, [], "Nothing after subscription")

        other.send(completion: .failure(.error))

        publisher.send("Hello")

        XCTAssertTrue(didCancelUpstream)
        XCTAssertEqual(receiver.values, [], "Still nothing after publish, if the other finish publish yet")
        XCTAssertEqual(receiver.completion, [])

        _ = subscription
    }
}
