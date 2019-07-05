//
//  FutureTests.swift
//  CombineHarvesterTests
//
//  Created by Andreas Hartl on 26.06.19.
//

import XCTest
@testable import CombineHarvester

class FutureTests: XCTestCase {
    func testSuccess() {
        var callback: ((Result<String, TestError>) -> Void)?
        var receiver: TestSubject<String, TestError>
        var subscription: Cancellable

        let publisher = Future { callback = $0 }

        XCTAssertNil(callback, "User does not get the callback before subscribing")

        receiver = TestSubject()

        subscription = publisher.subscribe(receiver)

        XCTAssertNotNil(callback, "User gets the callback after subscribing")
        XCTAssertEqual(receiver.values, [])
        XCTAssertEqual(receiver.completion, [])

        callback?(.success("Hello"))

        XCTAssertEqual(receiver.values, ["Hello"])
        XCTAssertEqual(receiver.completion, [.finished])

        callback?(.success("Hello again"))

        XCTAssertEqual(receiver.values, ["Hello"], "No changes if the callback has been called again")
        XCTAssertEqual(receiver.completion, [.finished])

        _ = subscription
    }

    func testCancel() {
        var callback: ((Result<String, TestError>) -> Void)?
        var receiver: TestSubject<String, TestError>
        var subscription: Cancellable

        let publisher = Future { callback = $0 }

        receiver = TestSubject()

        subscription = publisher.subscribe(receiver)
        subscription.cancel()

        callback?(.success("Hello"))
        XCTAssertNotNil(callback, "User gets the callback after subscribing")
        XCTAssertEqual(receiver.values, [], "No changes if the subscription was cancelled")
        XCTAssertEqual(receiver.completion, [])

        _ = subscription
    }

    func testFailed() {
        var callback: ((Result<String, TestError>) -> Void)?
        var receiver: TestSubject<String, TestError>
        var subscription: Cancellable

        let publisher = Future { callback = $0 }

        receiver = TestSubject()
        subscription = publisher.subscribe(receiver)

        callback?(.failure(.error))
        XCTAssertEqual(receiver.values, [])
        XCTAssertEqual(receiver.completion, [.failure(.error)])

        callback?(.failure(.otherError))
        XCTAssertEqual(receiver.values, [])
        XCTAssertEqual(receiver.completion, [.failure(.error)], "No changes after failure")

        callback?(.success("Foo"))
        XCTAssertEqual(receiver.values, [])
        XCTAssertEqual(receiver.completion, [.failure(.error)], "No changes after failure")

        _ = subscription
    }
}
