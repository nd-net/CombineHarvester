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
        let publisher = Just("Hello")
        _ = publisher.subscribe(subject)

        XCTAssertEqual(subject.values, ["Hello"])
        XCTAssertEqual(subject.completion, [.finished])
    }

    func testEquals() {
        XCTAssertEqual(Just("Hello"), Just("Hello"))
    }

    func testAllSatisfy() {
        XCTAssertEqual(Just("Hello").allSatisfy { $0 == "Hello" }, Just(true))
        XCTAssertEqual(Just("Hello").allSatisfy { $0 != "Hello" }, Just(false))

        XCTAssertEqual(
            Just("Hello")
                .tryAllSatisfy { $0 == "Hello" }
                .mapError { $0 as! TestError },
            Publishers.Once(true)
        )
        XCTAssertEqual(
            Just("Hello")
                .tryAllSatisfy { $0 != "Hello" }
                .mapError { $0 as! TestError },
            Publishers.Once(false)
        )
        XCTAssertEqual(
            Just("Hello")
                .tryAllSatisfy { _ in throw TestError.error }
                .mapError { $0 as! TestError },
            Publishers.Once(TestError.error)
        )
    }

    func testCollect() {
        XCTAssertEqual(Just("Hello").collect(), Just(["Hello"]))
    }

    func testCompactMap() {
        XCTAssertEqual(Just("Hello").compactMap { $0 }, Publishers.Optional("Hello"))
        XCTAssertEqual(Just("Hello").compactMap { _ -> Int? in nil }, Publishers.Optional(nil))

        XCTAssertEqual(
            Just("Hello")
                .tryCompactMap { $0 }
                .mapError { $0 as! TestError },
            Publishers.Optional("Hello")
        )
        XCTAssertEqual(
            Just("Hello")
                .tryCompactMap { _ -> Int? in nil }
                .mapError { $0 as! TestError },
            Publishers.Optional(nil)
        )
        XCTAssertEqual(
            Just("Hello")
                .tryCompactMap { _ -> Int? in throw TestError.error }
                .mapError { $0 as! TestError },
            Publishers.Optional(.error)
        )
    }

    func testMin() {
        XCTAssertEqual(Just("Hello").min(), Just("Hello"))
        XCTAssertEqual(Just("Hello").min(by: { _, _ in false }), Just("Hello"))
        XCTAssertEqual(Just("Hello").tryMin(by: { _, _ in throw TestError.error }), Just("Hello"))
    }

    func testMax() {
        XCTAssertEqual(Just("Hello").max(), Just("Hello"))
        XCTAssertEqual(Just("Hello").max(by: { _, _ in false }), Just("Hello"))
        XCTAssertEqual(Just("Hello").tryMax(by: { _, _ in throw TestError.error }), Just("Hello"))
    }

    func testContains() {
        XCTAssertEqual(Just("Hello").contains("Hello"), Just(true))
        XCTAssertEqual(Just("Hello").contains("Hi"), Just(false))

        XCTAssertEqual(Just("Hello").contains(where: { $0 == "Hello" }), Just(true))
        XCTAssertEqual(Just("Hello").contains(where: { $0 == "Hi" }), Just(false))

        XCTAssertEqual(
            Just("Hello")
                .tryContains(where: { $0 == "Hello" })
                .mapError { $0 as! TestError },
            Publishers.Once(true)
        )
        XCTAssertEqual(
            Just("Hello")
                .tryContains(where: { $0 == "Hi" })
                .mapError { $0 as! TestError },
            Publishers.Once(false)
        )
        XCTAssertEqual(
            Just("Hello")
                .tryContains(where: { _ in throw TestError.error })
                .mapError { $0 as! TestError },
            Publishers.Once(TestError.error)
        )
    }

    func testCount() {
        XCTAssertEqual(Just("Hello").count(), Just(1))
    }

    func testDrop() {
        XCTAssertEqual(Just("Hello").dropFirst(), Publishers.Optional(nil))
        XCTAssertEqual(Just("Hello").dropFirst(0), Publishers.Optional("Hello"))

        XCTAssertEqual(Just("Hello").drop { $0 == "Hello" }, Publishers.Optional(nil))
        XCTAssertEqual(Just("Hello").drop { $0 != "Hello" }, Publishers.Optional("Hello"))

        XCTAssertEqual(
            Just("Hello")
                .tryDrop { $0 == "Hello" }
                .mapError { $0 as! TestError },
            Publishers.Optional(nil)
        )
        XCTAssertEqual(
            Just("Hello")
                .tryDrop { $0 != "Hello" }
                .mapError { $0 as! TestError },
            Publishers.Optional("Hello")
        )
        XCTAssertEqual(
            Just("Hello")
                .tryDrop { _ in throw TestError.error }
                .mapError { $0 as! TestError },
            Publishers.Optional(.error)
        )
    }

    func testFirst() {
        XCTAssertEqual(Just("Hello").first(), Just("Hello"))

        XCTAssertEqual(Just("Hello").first { $0 == "Hello" }, Publishers.Optional("Hello"))
        XCTAssertEqual(Just("Hello").first { $0 != "Hello" }, Publishers.Optional(nil))

        XCTAssertEqual(
            Just("Hello")
                .tryFirst { $0 == "Hello" }
                .mapError { $0 as! TestError },
            Publishers.Optional("Hello")
        )
        XCTAssertEqual(
            Just("Hello")
                .tryFirst { $0 != "Hello" }
                .mapError { $0 as! TestError },
            Publishers.Optional(nil)
        )
        XCTAssertEqual(
            Just("Hello")
                .tryFirst { _ in throw TestError.error }
                .mapError { $0 as! TestError },
            Publishers.Optional(.error)
        )
    }

    func testLast() {
        XCTAssertEqual(Just("Hello").last(), Just("Hello"))

        XCTAssertEqual(Just("Hello").last { $0 == "Hello" }, Publishers.Optional("Hello"))
        XCTAssertEqual(Just("Hello").last { $0 != "Hello" }, Publishers.Optional(nil))

        XCTAssertEqual(
            Just("Hello")
                .tryLast { $0 == "Hello" }
                .mapError { $0 as! TestError },
            Publishers.Optional("Hello")
        )
        XCTAssertEqual(
            Just("Hello")
                .tryLast { $0 != "Hello" }
                .mapError { $0 as! TestError },
            Publishers.Optional(nil)
        )
        XCTAssertEqual(
            Just("Hello")
                .tryLast { _ in throw TestError.error }
                .mapError { $0 as! TestError },
            Publishers.Optional(.error)
        )
    }

    func testFilter() {
        XCTAssertEqual(Just("Hello").filter { $0 == "Hello" }, Publishers.Optional("Hello"))
        XCTAssertEqual(Just("Hello").filter { $0 != "Hello" }, Publishers.Optional(nil))

        XCTAssertEqual(
            Just("Hello")
                .tryFilter { $0 == "Hello" }
                .mapError { $0 as! TestError },
            Publishers.Optional("Hello")
        )
        XCTAssertEqual(
            Just("Hello")
                .tryFilter { $0 != "Hello" }
                .mapError { $0 as! TestError },
            Publishers.Optional(nil)
        )
        XCTAssertEqual(
            Just("Hello")
                .tryFilter { _ in throw TestError.error }
                .mapError { $0 as! TestError },
            Publishers.Optional(.error)
        )
    }

    func testIgnoreOutput() {
        XCTAssertEqual(Just("Hello").ignoreOutput(), Publishers.Empty())
    }

    func testMap() {
        XCTAssertEqual(Just("Hello").map { "!\($0)!" }, Just("!Hello!"))

        XCTAssertEqual(
            Just("Hello")
                .tryMap { "!\($0)!" }
                .mapError { $0 as! TestError },
            Publishers.Once("!Hello!")
        )
        XCTAssertEqual(
            Just("Hello")
                .tryMap { (_) -> String in throw TestError.error }
                .mapError { $0 as! TestError },
            Publishers.Once(TestError.error)
        )
    }

    func testMapError() {
        XCTAssertEqual(Just("Hello").mapError { _ in TestError.error }, Publishers.Once("Hello"))
    }

    func testOutput() {
        XCTAssertEqual(Just("Hello").output(at: 0), Publishers.Optional("Hello"))
        XCTAssertEqual(Just("Hello").output(at: 1), Publishers.Optional(nil))

        XCTAssertEqual(Just("Hello").output(in: ...1), Publishers.Optional("Hello"))
        XCTAssertEqual(Just("Hello").output(in: 1...), Publishers.Optional(nil))
    }

    func testPrefix() {
        XCTAssertEqual(Just("Hello").prefix(0), Publishers.Optional(nil))
        XCTAssertEqual(Just("Hello").prefix(1), Publishers.Optional("Hello"))

        XCTAssertEqual(Just("Hello").prefix(while: { $0 == "Hello" }), Publishers.Optional("Hello"))
        XCTAssertEqual(Just("Hello").prefix(while: { $0 != "Hello" }), Publishers.Optional(nil))

        XCTAssertEqual(
            Just("Hello")
                .tryPrefix(while: { $0 == "Hello" })
                .mapError { $0 as! TestError },
            Publishers.Optional("Hello")
        )
        XCTAssertEqual(
            Just("Hello")
                .tryPrefix(while: { $0 != "Hello" })
                .mapError { $0 as! TestError },
            Publishers.Optional(nil)
        )
        XCTAssertEqual(
            Just("Hello")
                .tryPrefix(while: { _ in throw TestError.error })
                .mapError { $0 as! TestError },
            Publishers.Optional(.error)
        )
    }

    func testPrepend() {
        XCTAssertEqual(Just("Hello").prepend(), Publishers.Sequence(sequence: ["Hello"]))
        XCTAssertEqual(Just("Hello").prepend("World"), Publishers.Sequence(sequence: ["World", "Hello"]))
        XCTAssertEqual(Just("Hello").prepend([]), Publishers.Sequence(sequence: ["Hello"]))
        XCTAssertEqual(Just("Hello").prepend(["World"]), Publishers.Sequence(sequence: ["World", "Hello"]))
    }

    func testAppend() {
        XCTAssertEqual(Just("Hello").append(), Publishers.Sequence(sequence: ["Hello"]))
        XCTAssertEqual(Just("Hello").append("World"), Publishers.Sequence(sequence: ["Hello", "World"]))
        XCTAssertEqual(Just("Hello").append([]), Publishers.Sequence(sequence: ["Hello"]))
        XCTAssertEqual(Just("Hello").append(["World"]), Publishers.Sequence(sequence: ["Hello", "World"]))
    }

    func testReduce() {
        XCTAssertEqual(Just("Hello").reduce(0) { $0 + $1.count }, Publishers.Once("Hello".count))

        XCTAssertEqual(
            Just("Hello")
                .tryReduce(0) { $0 + $1.count }
                .mapError { $0 as! TestError },
            Publishers.Once("Hello".count)
        )
        XCTAssertEqual(
            Just("Hello")
                .tryReduce(0) { _, _ in throw TestError.error }
                .mapError { $0 as! TestError },
            Publishers.Once(TestError.error)
        )
    }

    func testRemoveDuplicates() {
        XCTAssertEqual(Just("Hello").removeDuplicates(), Just("Hello"))
        XCTAssertEqual(Just("Hello").removeDuplicates(by: { _, _ in false }), Just("Hello"))

        XCTAssertEqual(
            Just("Hello")
                .tryRemoveDuplicates(by: { _, _ in false })
                .mapError { $0 as! TestError },
            Publishers.Once("Hello")
        )
        XCTAssertEqual(
            Just("Hello")
                .tryRemoveDuplicates(by: { _, _ in throw TestError.error })
                .mapError { $0 as! TestError },
            Publishers.Once("Hello")
        )
    }

    func testReplaceError() {
        XCTAssertEqual(Just("Hello").replaceError(with: "World"), Just("Hello"))
    }

    func testReplaceEmpty() {
        XCTAssertEqual(Just("Hello").replaceEmpty(with: "World"), Just("Hello"))
    }

    func testRetry() {
        XCTAssertEqual(Just("Hello").retry(42), Just("Hello"))
        XCTAssertEqual(Just("Hello").retry(), Just("Hello"))
    }

    func testScan() {
        XCTAssertEqual(Just("Hello").scan(0) { $0 + $1.count }, Publishers.Once("Hello".count))

        XCTAssertEqual(
            Just("Hello")
                .tryScan(0) { $0 + $1.count }
                .mapError { $0 as! TestError },
            Publishers.Once("Hello".count)
        )
        XCTAssertEqual(
            Just("Hello")
                .tryScan(0) { _, _ in throw TestError.error }
                .mapError { $0 as! TestError },
            Publishers.Once(.error)
        )
    }
}
