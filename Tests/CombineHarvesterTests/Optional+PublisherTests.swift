//
//  OptionalTests.swift
//  CombineHarvesterTests
//
//  Created by Andreas Hartl on 19.06.19.
//

import XCTest
@testable import CombineHarvester

class OptionalTests: XCTestCase {
    typealias PublishersOptional<Output> = Optional<Output>.OptionalPublisher
    typealias TestOptional = PublishersOptional<String>

    func testSubscribe() {
        var subject = TestSubject<String, Never>()
        var publisher = TestOptional("Hello")
        _ = publisher.subscribe(subject)

        XCTAssertEqual(subject.values, ["Hello"])
        XCTAssertEqual(subject.completion, [.finished])

        subject = TestSubject()
        publisher = PublishersOptional(nil)
        _ = publisher.subscribe(subject)

        XCTAssertEqual(subject.values, [])
        XCTAssertEqual(subject.completion, [.finished])
    }

    func testEquals() {
        XCTAssertEqual(TestOptional("Hello"), TestOptional("Hello"))
        XCTAssertEqual(TestOptional(nil), TestOptional(nil))
    }

    func testAllSatisfy() {
        XCTAssertEqual(TestOptional(nil).allSatisfy { $0 == "Hello" }, PublishersOptional(nil))
        XCTAssertEqual(TestOptional("Hello").allSatisfy { $0 == "Hello" }, PublishersOptional(true))
        XCTAssertEqual(TestOptional("Hello").allSatisfy { $0 != "Hello" }, PublishersOptional(false))
    }

    func testCollect() {
        XCTAssertEqual(TestOptional(nil).collect(), PublishersOptional(nil))
        XCTAssertEqual(TestOptional("Hello").collect(), PublishersOptional(["Hello"]))
    }

    func testCompactMap() {
        XCTAssertEqual(TestOptional(nil).compactMap { $0 }, PublishersOptional(nil))
        XCTAssertEqual(TestOptional("Hello").compactMap { $0 }, PublishersOptional("Hello"))
        XCTAssertEqual(TestOptional("Hello").compactMap { _ -> Int? in nil }, PublishersOptional(nil))
    }

    func testMin() {
        XCTAssertEqual(TestOptional(nil).min(), PublishersOptional(nil))
        XCTAssertEqual(TestOptional(nil).min(by: { _, _ in false }), PublishersOptional(nil))
        XCTAssertEqual(TestOptional("Hello").min(), PublishersOptional("Hello"))
        XCTAssertEqual(TestOptional("Hello").min(by: { _, _ in false }), PublishersOptional("Hello"))
    }

    func testMax() {
        XCTAssertEqual(TestOptional(nil).max(), PublishersOptional(nil))
        XCTAssertEqual(TestOptional(nil).max(by: { _, _ in false }), PublishersOptional(nil))
        XCTAssertEqual(TestOptional("Hello").max(), PublishersOptional("Hello"))
        XCTAssertEqual(TestOptional("Hello").max(by: { _, _ in false }), PublishersOptional("Hello"))
    }

    func testContains() {
        XCTAssertEqual(TestOptional(nil).contains("Hello"), PublishersOptional(nil))
        XCTAssertEqual(TestOptional("Hello").contains("Hello"), PublishersOptional(true))
        XCTAssertEqual(TestOptional("Hello").contains("Hi"), PublishersOptional(false))

        XCTAssertEqual(TestOptional(nil).contains(where: { $0 == "Hello" }), PublishersOptional(nil))
        XCTAssertEqual(TestOptional("Hello").contains(where: { $0 == "Hello" }), PublishersOptional(true))
        XCTAssertEqual(TestOptional("Hello").contains(where: { $0 == "Hi" }), PublishersOptional(false))
    }

    func testCount() {
        XCTAssertEqual(TestOptional(nil).count(), Just(0))
        XCTAssertEqual(TestOptional("Hello").count(), Just(1))
    }

    func testDrop() {
        XCTAssertEqual(TestOptional(nil).dropFirst(), PublishersOptional(nil))
        XCTAssertEqual(TestOptional("Hello").dropFirst(), PublishersOptional(nil))
        XCTAssertEqual(TestOptional("Hello").dropFirst(0), PublishersOptional("Hello"))

        XCTAssertEqual(TestOptional(nil).drop { $0 == "Hello" }, PublishersOptional(nil))
        XCTAssertEqual(TestOptional("Hello").drop { $0 == "Hello" }, PublishersOptional(nil))
        XCTAssertEqual(TestOptional("Hello").drop { $0 != "Hello" }, PublishersOptional("Hello"))
    }

    func testFirst() {
        XCTAssertEqual(TestOptional(nil).first(), PublishersOptional(nil))
        XCTAssertEqual(TestOptional("Hello").first(), PublishersOptional("Hello"))

        XCTAssertEqual(TestOptional(nil).first { $0 == "Hello" }, PublishersOptional(nil))
        XCTAssertEqual(TestOptional("Hello").first { $0 == "Hello" }, PublishersOptional("Hello"))
        XCTAssertEqual(TestOptional("Hello").first { $0 != "Hello" }, PublishersOptional(nil))
    }

    func testLast() {
        XCTAssertEqual(TestOptional(nil).last(), PublishersOptional(nil))
        XCTAssertEqual(TestOptional("Hello").last(), PublishersOptional("Hello"))

        XCTAssertEqual(TestOptional(nil).last { $0 == "Hello" }, PublishersOptional(nil))
        XCTAssertEqual(TestOptional("Hello").last { $0 == "Hello" }, PublishersOptional("Hello"))
        XCTAssertEqual(TestOptional("Hello").last { $0 != "Hello" }, PublishersOptional(nil))
    }

    func testFilter() {
        XCTAssertEqual(TestOptional(nil).filter { $0 == "Hello" }, PublishersOptional(nil))
        XCTAssertEqual(TestOptional("Hello").filter { $0 == "Hello" }, PublishersOptional("Hello"))
        XCTAssertEqual(TestOptional("Hello").filter { $0 != "Hello" }, PublishersOptional(nil))
    }

    func testIgnoreOutput() {
        XCTAssertEqual(TestOptional(nil).ignoreOutput(), Publishers.Empty())
        XCTAssertEqual(TestOptional("Hello").ignoreOutput(), Publishers.Empty())
    }

    func testMap() {
        XCTAssertEqual(TestOptional(nil).map { "!\($0)!" }, PublishersOptional(nil))
        XCTAssertEqual(TestOptional("Hello").map { "!\($0)!" }, PublishersOptional("!Hello!"))
    }

    func testOutput() {
        XCTAssertEqual(TestOptional(nil).output(at: 0), PublishersOptional(nil))
        XCTAssertEqual(TestOptional("Hello").output(at: 0), PublishersOptional("Hello"))
        XCTAssertEqual(TestOptional("Hello").output(at: 1), PublishersOptional(nil))

        XCTAssertEqual(TestOptional(nil).output(in: ...1), PublishersOptional(nil))
        XCTAssertEqual(TestOptional("Hello").output(in: ...1), PublishersOptional("Hello"))
        XCTAssertEqual(TestOptional("Hello").output(in: 1...), PublishersOptional(nil))
    }

    func testPrefix() {
        XCTAssertEqual(TestOptional(nil).prefix(0), PublishersOptional(nil))
        XCTAssertEqual(TestOptional("Hello").prefix(0), PublishersOptional(nil))
        XCTAssertEqual(TestOptional("Hello").prefix(1), PublishersOptional("Hello"))

        XCTAssertEqual(TestOptional(nil).prefix(while: { $0 == "Hello" }), PublishersOptional(nil))
        XCTAssertEqual(TestOptional("Hello").prefix(while: { $0 == "Hello" }), PublishersOptional("Hello"))
        XCTAssertEqual(TestOptional("Hello").prefix(while: { $0 != "Hello" }), PublishersOptional(nil))
    }

    func testReduce() {
        XCTAssertEqual(TestOptional(nil).reduce(0) { $0 + $1.count }, PublishersOptional(nil))
        XCTAssertEqual(TestOptional("Hello").reduce(0) { $0 + $1.count }, PublishersOptional("Hello".count))
    }

    func testRemoveDuplicates() {
        XCTAssertEqual(TestOptional(nil).removeDuplicates(), PublishersOptional(nil))
        XCTAssertEqual(TestOptional(nil).removeDuplicates(by: { _, _ in false }), PublishersOptional(nil))
        XCTAssertEqual(TestOptional("Hello").removeDuplicates(), PublishersOptional("Hello"))
        XCTAssertEqual(TestOptional("Hello").removeDuplicates(by: { _, _ in false }), PublishersOptional("Hello"))
    }

    func testReplaceEmpty() {
        XCTAssertEqual(TestOptional(nil).replaceEmpty(with: "World"), Just("World"))
        XCTAssertEqual(TestOptional("Hello").replaceEmpty(with: "World"), Just("Hello"))
    }

    func testRetry() {
        XCTAssertEqual(TestOptional(nil).retry(42), PublishersOptional(nil))
        XCTAssertEqual(TestOptional(nil).retry(), PublishersOptional(nil))
        XCTAssertEqual(TestOptional("Hello").retry(42), PublishersOptional("Hello"))
        XCTAssertEqual(TestOptional("Hello").retry(), PublishersOptional("Hello"))
    }

    func testScan() {
        XCTAssertEqual(TestOptional(nil).scan(0) { $0 + $1.count }, PublishersOptional(nil))
        XCTAssertEqual(TestOptional("Hello").scan(0) { $0 + $1.count }, PublishersOptional("Hello".count))
    }
}
