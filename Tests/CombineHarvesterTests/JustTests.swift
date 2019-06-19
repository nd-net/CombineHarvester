//
//  JustTests.swift
//  CombineHarvesterTests
//
//  Created by Andreas Hartl on 19.06.19.
//

import XCTest
@testable import CombineHarvester

class JustTests: XCTestCase {
    func testSubscribe() {
        let subject = TestSubject<String, Never>()
        let publisher = Publishers.Just("Hello")
        _ = publisher.subscribe(subject)

        XCTAssertEqual(subject.values, ["Hello"])
        XCTAssertEqual(subject.completion, [.finished])
    }

    func testEquals() {
        XCTAssertEqual(Publishers.Just("Hello"), Publishers.Just("Hello"))
    }

    func testAllSatisfy() {
        XCTAssertEqual(Publishers.Just("Hello").allSatisfy { $0 == "Hello" }, Publishers.Just(true))
        XCTAssertEqual(Publishers.Just("Hello").allSatisfy { $0 != "Hello" }, Publishers.Just(false))
    }

    func testCollect() {
        XCTAssertEqual(Publishers.Just("Hello").collect(), Publishers.Just(["Hello"]))
    }

    func testMin() {
        XCTAssertEqual(Publishers.Just("Hello").min(), Publishers.Just("Hello"))
        XCTAssertEqual(Publishers.Just("Hello").min(by: { _, _ in false }), Publishers.Just("Hello"))
        XCTAssertEqual(Publishers.Just("Hello").tryMin(by: { _, _ in throw TestError.error }), Publishers.Just("Hello"))
    }

    func testMax() {
        XCTAssertEqual(Publishers.Just("Hello").max(), Publishers.Just("Hello"))
        XCTAssertEqual(Publishers.Just("Hello").max(by: { _, _ in false }), Publishers.Just("Hello"))
        XCTAssertEqual(Publishers.Just("Hello").tryMax(by: { _, _ in throw TestError.error }), Publishers.Just("Hello"))
    }

    func testContains() {
        XCTAssertEqual(Publishers.Just("Hello").contains("Hello"), Publishers.Just(true))
        XCTAssertEqual(Publishers.Just("Hello").contains("Hi"), Publishers.Just(false))
        XCTAssertEqual(Publishers.Just("Hello").contains(where: { $0 == "Hello" }), Publishers.Just(true))
        XCTAssertEqual(Publishers.Just("Hello").contains(where: { $0 == "Hi" }), Publishers.Just(false))
    }

    func testCount() {
        XCTAssertEqual(Publishers.Just("Hello").count(), Publishers.Just(1))
    }

    func testFirst() {
        XCTAssertEqual(Publishers.Just("Hello").first(), Publishers.Just("Hello"))
    }

    func testLast() {
        XCTAssertEqual(Publishers.Just("Hello").last(), Publishers.Just("Hello"))
    }

    func testIgnoreOutput() {
        XCTAssertEqual(Publishers.Just("Hello").ignoreOutput(), Publishers.Empty())
    }

    func testMap() {
        XCTAssertEqual(Publishers.Just("Hello").map { "!\($0)!" }, Publishers.Just("!Hello!"))
    }

    func testRemoveDuplicates() {
        XCTAssertEqual(Publishers.Just("Hello").removeDuplicates(), Publishers.Just("Hello"))
        XCTAssertEqual(Publishers.Just("Hello").removeDuplicates(by: { _, _ in false }), Publishers.Just("Hello"))
    }

    func testReplaceError() {
        XCTAssertEqual(Publishers.Just("Hello").replaceError(with: ""), Publishers.Just("Hello"))
    }

    func testReplaceEmpty() {
        XCTAssertEqual(Publishers.Just("Hello").replaceEmpty(with: ""), Publishers.Just("Hello"))
    }

    func testRetry() {
        XCTAssertEqual(Publishers.Just("Hello").retry(42), Publishers.Just("Hello"))
        XCTAssertEqual(Publishers.Just("Hello").retry(), Publishers.Just("Hello"))
    }
}
