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

        XCTAssertEqual(
            Publishers.Just("Hello")
                .tryAllSatisfy { $0 == "Hello" }
                .mapError { $0 as! TestError },
            Publishers.Once(true)
        )
        XCTAssertEqual(
            Publishers.Just("Hello")
                .tryAllSatisfy { $0 != "Hello" }
                .mapError { $0 as! TestError },
            Publishers.Once(false)
        )
        XCTAssertEqual(
            Publishers.Just("Hello")
                .tryAllSatisfy { _ in throw TestError.error }
                .mapError { $0 as! TestError },
            Publishers.Once(TestError.error)
        )
    }

    func testCollect() {
        XCTAssertEqual(Publishers.Just("Hello").collect(), Publishers.Just(["Hello"]))
    }

    func testCompactMap() {
        XCTAssertEqual(Publishers.Just("Hello").compactMap { $0 }, Publishers.Optional("Hello"))
        XCTAssertEqual(Publishers.Just("Hello").compactMap { _ -> Int? in nil }, Publishers.Optional(nil))

        XCTAssertEqual(
            Publishers.Just("Hello")
                .tryCompactMap { $0 }
                .mapError { $0 as! TestError },
            Publishers.Optional("Hello")
        )
        XCTAssertEqual(
            Publishers.Just("Hello")
                .tryCompactMap { _ -> Int? in nil }
                .mapError { $0 as! TestError },
            Publishers.Optional(nil)
        )
        XCTAssertEqual(
            Publishers.Just("Hello")
                .tryCompactMap { _ -> Int? in throw TestError.error }
                .mapError { $0 as! TestError },
            Publishers.Optional(.error)
        )
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

        XCTAssertEqual(
            Publishers.Just("Hello")
                .tryContains(where: { $0 == "Hello" })
                .mapError { $0 as! TestError },
            Publishers.Once(true)
        )
        XCTAssertEqual(
            Publishers.Just("Hello")
                .tryContains(where: { $0 == "Hi" })
                .mapError { $0 as! TestError },
            Publishers.Once(false)
        )
        XCTAssertEqual(
            Publishers.Just("Hello")
                .tryContains(where: { _ in throw TestError.error })
                .mapError { $0 as! TestError },
            Publishers.Once(TestError.error)
        )
    }

    func testCount() {
        XCTAssertEqual(Publishers.Just("Hello").count(), Publishers.Just(1))
    }

    func testDrop() {
        XCTAssertEqual(Publishers.Just("Hello").dropFirst(), Publishers.Optional(nil))
        XCTAssertEqual(Publishers.Just("Hello").dropFirst(0), Publishers.Optional("Hello"))

        XCTAssertEqual(Publishers.Just("Hello").drop { $0 == "Hello" }, Publishers.Optional(nil))
        XCTAssertEqual(Publishers.Just("Hello").drop { $0 != "Hello" }, Publishers.Optional("Hello"))

        XCTAssertEqual(
            Publishers.Just("Hello")
                .tryDrop { $0 == "Hello" }
                .mapError { $0 as! TestError },
            Publishers.Optional(nil)
        )
        XCTAssertEqual(
            Publishers.Just("Hello")
                .tryDrop { $0 != "Hello" }
                .mapError { $0 as! TestError },
            Publishers.Optional("Hello")
        )
        XCTAssertEqual(
            Publishers.Just("Hello")
                .tryDrop { _ in throw TestError.error }
                .mapError { $0 as! TestError },
            Publishers.Optional(.error)
        )
    }

    func testFirst() {
        XCTAssertEqual(Publishers.Just("Hello").first(), Publishers.Just("Hello"))

        XCTAssertEqual(Publishers.Just("Hello").first { $0 == "Hello" }, Publishers.Optional("Hello"))
        XCTAssertEqual(Publishers.Just("Hello").first { $0 != "Hello" }, Publishers.Optional(nil))

        XCTAssertEqual(
            Publishers.Just("Hello")
                .tryFirst { $0 == "Hello" }
                .mapError { $0 as! TestError },
            Publishers.Optional("Hello")
        )
        XCTAssertEqual(
            Publishers.Just("Hello")
                .tryFirst { $0 != "Hello" }
                .mapError { $0 as! TestError },
            Publishers.Optional(nil)
        )
        XCTAssertEqual(
            Publishers.Just("Hello")
                .tryFirst { _ in throw TestError.error }
                .mapError { $0 as! TestError },
            Publishers.Optional(.error)
        )
    }

    func testLast() {
        XCTAssertEqual(Publishers.Just("Hello").last(), Publishers.Just("Hello"))

        XCTAssertEqual(Publishers.Just("Hello").last { $0 == "Hello" }, Publishers.Optional("Hello"))
        XCTAssertEqual(Publishers.Just("Hello").last { $0 != "Hello" }, Publishers.Optional(nil))

        XCTAssertEqual(
            Publishers.Just("Hello")
                .tryLast { $0 == "Hello" }
                .mapError { $0 as! TestError },
            Publishers.Optional("Hello")
        )
        XCTAssertEqual(
            Publishers.Just("Hello")
                .tryLast { $0 != "Hello" }
                .mapError { $0 as! TestError },
            Publishers.Optional(nil)
        )
        XCTAssertEqual(
            Publishers.Just("Hello")
                .tryLast { _ in throw TestError.error }
                .mapError { $0 as! TestError },
            Publishers.Optional(.error)
        )
    }

    func testFilter() {
        XCTAssertEqual(Publishers.Just("Hello").filter { $0 == "Hello" }, Publishers.Optional("Hello"))
        XCTAssertEqual(Publishers.Just("Hello").filter { $0 != "Hello" }, Publishers.Optional(nil))

        XCTAssertEqual(
            Publishers.Just("Hello")
                .tryFilter { $0 == "Hello" }
                .mapError { $0 as! TestError },
            Publishers.Optional("Hello")
        )
        XCTAssertEqual(
            Publishers.Just("Hello")
                .tryFilter { $0 != "Hello" }
                .mapError { $0 as! TestError },
            Publishers.Optional(nil)
        )
        XCTAssertEqual(
            Publishers.Just("Hello")
                .tryFilter { _ in throw TestError.error }
                .mapError { $0 as! TestError },
            Publishers.Optional(.error)
        )
    }

    func testIgnoreOutput() {
        XCTAssertEqual(Publishers.Just("Hello").ignoreOutput(), Publishers.Empty())
    }

    func testMap() {
        XCTAssertEqual(Publishers.Just("Hello").map { "!\($0)!" }, Publishers.Just("!Hello!"))

        XCTAssertEqual(
            Publishers.Just("Hello")
                .tryMap { "!\($0)!" }
                .mapError { $0 as! TestError },
            Publishers.Once("!Hello!")
        )
        XCTAssertEqual(
            Publishers.Just("Hello")
                .tryMap { (_) -> String in throw TestError.error }
                .mapError { $0 as! TestError },
            Publishers.Once(TestError.error)
        )
    }

    func testMapError() {
        XCTAssertEqual(Publishers.Just("Hello").mapError { _ in TestError.error }, Publishers.Once("Hello"))
    }

    func testOutput() {
        XCTAssertEqual(Publishers.Just("Hello").output(at: 0), Publishers.Optional("Hello"))
        XCTAssertEqual(Publishers.Just("Hello").output(at: 1), Publishers.Optional(nil))

        XCTAssertEqual(Publishers.Just("Hello").output(in: ...1), Publishers.Optional("Hello"))
        XCTAssertEqual(Publishers.Just("Hello").output(in: 1...), Publishers.Optional(nil))
    }

    func testPrefix() {
        XCTAssertEqual(Publishers.Just("Hello").prefix(0), Publishers.Optional(nil))
        XCTAssertEqual(Publishers.Just("Hello").prefix(1), Publishers.Optional("Hello"))

        XCTAssertEqual(Publishers.Just("Hello").prefix(while: { $0 == "Hello" }), Publishers.Optional("Hello"))
        XCTAssertEqual(Publishers.Just("Hello").prefix(while: { $0 != "Hello" }), Publishers.Optional(nil))

        XCTAssertEqual(
            Publishers.Just("Hello")
                .tryPrefix(while: { $0 == "Hello" })
                .mapError { $0 as! TestError },
            Publishers.Optional("Hello")
        )
        XCTAssertEqual(
            Publishers.Just("Hello")
                .tryPrefix(while: { $0 != "Hello" })
                .mapError { $0 as! TestError },
            Publishers.Optional(nil)
        )
        XCTAssertEqual(
            Publishers.Just("Hello")
                .tryPrefix(while: { _ in throw TestError.error })
                .mapError { $0 as! TestError },
            Publishers.Optional(.error)
        )
    }

    func testReduce() {
        XCTAssertEqual(Publishers.Just("Hello").reduce(0) { $0 + $1.count }, Publishers.Once("Hello".count))

        XCTAssertEqual(
            Publishers.Just("Hello")
                .tryReduce(0) { $0 + $1.count }
                .mapError { $0 as! TestError },
            Publishers.Once("Hello".count)
        )
        XCTAssertEqual(
            Publishers.Just("Hello")
                .tryReduce(0) { _, _ in throw TestError.error }
                .mapError { $0 as! TestError },
            Publishers.Once(TestError.error)
        )
    }

    func testRemoveDuplicates() {
        XCTAssertEqual(Publishers.Just("Hello").removeDuplicates(), Publishers.Just("Hello"))
        XCTAssertEqual(Publishers.Just("Hello").removeDuplicates(by: { _, _ in false }), Publishers.Just("Hello"))

        XCTAssertEqual(
            Publishers.Just("Hello")
                .tryRemoveDuplicates(by: { _, _ in false })
                .mapError { $0 as! TestError },
            Publishers.Once("Hello")
        )
        XCTAssertEqual(
            Publishers.Just("Hello")
                .tryRemoveDuplicates(by: { _, _ in throw TestError.error })
                .mapError { $0 as! TestError },
            Publishers.Once("Hello")
        )
    }

    func testReplaceError() {
        XCTAssertEqual(Publishers.Just("Hello").replaceError(with: "World"), Publishers.Just("Hello"))
    }

    func testReplaceEmpty() {
        XCTAssertEqual(Publishers.Just("Hello").replaceEmpty(with: "World"), Publishers.Just("Hello"))
    }

    func testRetry() {
        XCTAssertEqual(Publishers.Just("Hello").retry(42), Publishers.Just("Hello"))
        XCTAssertEqual(Publishers.Just("Hello").retry(), Publishers.Just("Hello"))
    }

    func testScan() {
        XCTAssertEqual(Publishers.Just("Hello").scan(0) { $0 + $1.count }, Publishers.Once("Hello".count))

        XCTAssertEqual(
            Publishers.Just("Hello")
                .tryScan(0) { $0 + $1.count }
                .mapError { $0 as! TestError },
            Publishers.Once("Hello".count)
        )
        XCTAssertEqual(
            Publishers.Just("Hello")
                .tryScan(0) { _, _ in throw TestError.error }
                .mapError { $0 as! TestError },
            Publishers.Once(.error)
        )
    }
}
