//
//  PrefixUntilOutputTests.swift
//  CombineHarvesterTests
//
//  Created by Andreas Hartl on 27.06.19.
//

import XCTest

import XCTest
@testable import CombineHarvester

class PrefixUntilOutputTests: XCTestCase {
    func testPrefixBeforeOther() {
        var didCancelOther = false
        let publisher = PassthroughSubject<String, TestError>()
        let other = PassthroughSubject<String, TestError>()
        var receiver: TestSubject<String, TestError>

        receiver = TestSubject()

        let subscription = publisher.prefix(untilOutputFrom: other.handleEvents(receiveCancel: { didCancelOther = true })).subscribe(receiver)

        XCTAssertEqual(receiver.values, [], "Nothing after subscription")
        XCTAssertEqual(receiver.completion, [], "Nothing after subscription")

        publisher.send("Hello")

        XCTAssertEqual(receiver.values, ["Hello"], "Values are passed through")
        XCTAssertEqual(receiver.completion, [])

        publisher.send("World")

        XCTAssertEqual(receiver.values, ["Hello", "World"], "Values are passed through")
        XCTAssertEqual(receiver.completion, [])

        other.send("X")

        XCTAssertTrue(didCancelOther)
        XCTAssertEqual(receiver.values, ["Hello", "World"])
        XCTAssertEqual(receiver.completion, [.finished], "Finishes after other sent a value")

        publisher.send("World")

        XCTAssertEqual(receiver.values, ["Hello", "World"])

        _ = subscription
    }

    func testUpstreamFinished() {
        var didCancelOther = false
        let publisher = PassthroughSubject<String, TestError>()
        let other = PassthroughSubject<String, TestError>()
        var receiver: TestSubject<String, TestError>

        receiver = TestSubject()

        let subscription = publisher.prefix(untilOutputFrom: other.handleEvents(receiveCancel: { didCancelOther = true })).subscribe(receiver)

        XCTAssertFalse(didCancelOther)

        publisher.send(completion: .finished)

        XCTAssertTrue(didCancelOther)

        _ = subscription
    }

    func testOtherFinishesWithoutData() {
        let publisher = PassthroughSubject<String, TestError>()
        let other = PassthroughSubject<String, TestError>()
        var receiver: TestSubject<String, TestError>

        receiver = TestSubject()

        let subscription = publisher.prefix(untilOutputFrom: other).subscribe(receiver)

        XCTAssertEqual(receiver.values, [], "Nothing after subscription")
        XCTAssertEqual(receiver.completion, [], "Nothing after subscription")

        other.send(completion: .finished)

        publisher.send("Hello")

        XCTAssertEqual(receiver.values, ["Hello"])
        XCTAssertEqual(receiver.completion, [])

        publisher.send(completion: .finished)

        XCTAssertEqual(receiver.values, ["Hello"])
        XCTAssertEqual(receiver.completion, [.finished])

        _ = subscription
    }

    func testOtherFinishesWithError() {
        let publisher = PassthroughSubject<String, TestError>()
        let other = PassthroughSubject<String, TestError>()
        var receiver: TestSubject<String, TestError>

        receiver = TestSubject()

        let subscription = publisher.prefix(untilOutputFrom: other).subscribe(receiver)

        XCTAssertEqual(receiver.values, [], "Nothing after subscription")
        XCTAssertEqual(receiver.completion, [], "Nothing after subscription")

        other.send(completion: .failure(.error))

        publisher.send("Hello")

        XCTAssertEqual(receiver.values, ["Hello"])
        XCTAssertEqual(receiver.completion, [])

        publisher.send(completion: .finished)

        XCTAssertEqual(receiver.values, ["Hello"])
        XCTAssertEqual(receiver.completion, [.finished])

        _ = subscription
    }
}
