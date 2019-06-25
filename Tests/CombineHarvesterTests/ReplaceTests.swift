//
//  ReplaceTests.swift
//  CombineHarvesterTests
//
//  Created by Andreas Hartl on 25.06.19.
//

import XCTest
@testable import CombineHarvester

class ReplaceTests: XCTestCase {
    func testReplaceEmpty() {
        var publisher: TestPublisher<String, TestError>
        var receiver: TestSubject<String, TestError>

        publisher = TestPublisher.success(["Hello"])
        receiver = TestSubject()
        _ = publisher.replaceEmpty(with: "World").subscribe(receiver)

        XCTAssertEqual(receiver.values, ["Hello"])
        XCTAssertEqual(receiver.completion, [.finished])

        publisher = TestPublisher.success([])
        receiver = TestSubject()
        _ = publisher.replaceEmpty(with: "World").subscribe(receiver)

        XCTAssertEqual(receiver.values, ["World"])
        XCTAssertEqual(receiver.completion, [.finished])

        publisher = TestPublisher(.failure(.error))
        receiver = TestSubject()
        _ = publisher.replaceEmpty(with: "World").subscribe(receiver)

        XCTAssertEqual(receiver.values, [])
        XCTAssertEqual(receiver.completion, [.failure(.error)])
    }

    func testReplaceError() {
        var publisher: TestPublisher<String, TestError>
        var receiver: TestSubject<String, Never>

        publisher = TestPublisher.success(["Hello"])
        receiver = TestSubject()
        _ = publisher.replaceError(with: "World").subscribe(receiver)

        XCTAssertEqual(receiver.values, ["Hello"])
        XCTAssertEqual(receiver.completion, [.finished])

        publisher = TestPublisher.success([])
        receiver = TestSubject()
        _ = publisher.replaceError(with: "World").subscribe(receiver)

        XCTAssertEqual(receiver.values, [])
        XCTAssertEqual(receiver.completion, [.finished])

        publisher = TestPublisher(.failure(.error))
        receiver = TestSubject()
        _ = publisher.replaceError(with: "World").subscribe(receiver)

        XCTAssertEqual(receiver.values, ["World"])
        XCTAssertEqual(receiver.completion, [.finished])

        publisher = TestPublisher(.success("Hello"), .failure(.error))
        receiver = TestSubject()
        _ = publisher.replaceError(with: "World").subscribe(receiver)

        XCTAssertEqual(receiver.values, ["Hello", "World"])
        XCTAssertEqual(receiver.completion, [.finished])
    }
}
