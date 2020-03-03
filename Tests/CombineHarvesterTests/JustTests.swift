//
//  JustTests.swift
//  CombineHarvesterTests
//
//  Created by Andreas Hartl on 19.06.19.
//

import XCTest
@testable import CombineHarvester

class JustTests: XCTestCase {
    typealias ResultPublisher<Output, Failure: Error> = Result<Output, Failure>.ResultPublisher

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
            ResultPublisher(true)
        )
        XCTAssertEqual(
            Just("Hello")
                .tryAllSatisfy { $0 != "Hello" }
                .mapError { $0 as! TestError },
            ResultPublisher(false)
        )
        XCTAssertEqual(
            Just("Hello")
                .tryAllSatisfy { _ in throw TestError.error }
                .mapError { $0 as! TestError },
            ResultPublisher(TestError.error)
        )
    }

    func testCollect() {
        XCTAssertEqual(Just("Hello").collect(), Just(["Hello"]))
    }

    func testCompactMap() {
        XCTAssertEqual(Just("Hello").compactMap { $0 }, Optional.OptionalPublisher("Hello"))
        XCTAssertEqual(Just("Hello").compactMap { _ -> Int? in nil }, Optional.OptionalPublisher(nil))
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
            ResultPublisher(true)
        )
        XCTAssertEqual(
            Just("Hello")
                .tryContains(where: { $0 == "Hi" })
                .mapError { $0 as! TestError },
            ResultPublisher(false)
        )
        XCTAssertEqual(
            Just("Hello")
                .tryContains(where: { _ in throw TestError.error })
                .mapError { $0 as! TestError },
            ResultPublisher(TestError.error)
        )
    }

    func testCount() {
        XCTAssertEqual(Just("Hello").count(), Just(1))
    }

    func testDrop() {
        XCTAssertEqual(Just("Hello").dropFirst(), Optional.OptionalPublisher(nil))
        XCTAssertEqual(Just("Hello").dropFirst(0), Optional.OptionalPublisher("Hello"))

        XCTAssertEqual(Just("Hello").drop { $0 == "Hello" }, Optional.OptionalPublisher(nil))
        XCTAssertEqual(Just("Hello").drop { $0 != "Hello" }, Optional.OptionalPublisher("Hello"))
    }

    func testFirst() {
        XCTAssertEqual(Just("Hello").first(), Just("Hello"))

        XCTAssertEqual(Just("Hello").first { $0 == "Hello" }, Optional.OptionalPublisher("Hello"))
        XCTAssertEqual(Just("Hello").first { $0 != "Hello" }, Optional.OptionalPublisher(nil))
    }

    func testLast() {
        XCTAssertEqual(Just("Hello").last(), Just("Hello"))

        XCTAssertEqual(Just("Hello").last { $0 == "Hello" }, Optional.OptionalPublisher("Hello"))
        XCTAssertEqual(Just("Hello").last { $0 != "Hello" }, Optional.OptionalPublisher(nil))
    }

    func testFilter() {
        XCTAssertEqual(Just("Hello").filter { $0 == "Hello" }, Optional.OptionalPublisher("Hello"))
        XCTAssertEqual(Just("Hello").filter { $0 != "Hello" }, Optional.OptionalPublisher(nil))
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
            ResultPublisher("!Hello!")
        )
        XCTAssertEqual(
            Just("Hello")
                .tryMap { (_) -> String in throw TestError.error }
                .mapError { $0 as! TestError },
            ResultPublisher(TestError.error)
        )
    }

    func testMapError() {
        XCTAssertEqual(Just("Hello").mapError { _ in TestError.error }, ResultPublisher("Hello"))
    }

    func testOutput() {
        XCTAssertEqual(Just("Hello").output(at: 0), Optional.OptionalPublisher("Hello"))
        XCTAssertEqual(Just("Hello").output(at: 1), Optional.OptionalPublisher(nil))

        XCTAssertEqual(Just("Hello").output(in: ...1), Optional.OptionalPublisher("Hello"))
        XCTAssertEqual(Just("Hello").output(in: 1...), Optional.OptionalPublisher(nil))
    }

    func testPrefix() {
        XCTAssertEqual(Just("Hello").prefix(0), Optional.OptionalPublisher(nil))
        XCTAssertEqual(Just("Hello").prefix(1), Optional.OptionalPublisher("Hello"))

        XCTAssertEqual(Just("Hello").prefix(while: { $0 == "Hello" }), Optional.OptionalPublisher("Hello"))
        XCTAssertEqual(Just("Hello").prefix(while: { $0 != "Hello" }), Optional.OptionalPublisher(nil))
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
        XCTAssertEqual(Just("Hello").reduce(0) { $0 + $1.count }, ResultPublisher("Hello".count))

        XCTAssertEqual(
            Just("Hello")
                .tryReduce(0) { $0 + $1.count }
                .mapError { $0 as! TestError },
            ResultPublisher("Hello".count)
        )
        XCTAssertEqual(
            Just("Hello")
                .tryReduce(0) { _, _ in throw TestError.error }
                .mapError { $0 as! TestError },
            ResultPublisher(TestError.error)
        )
    }

    func testRemoveDuplicates() {
        XCTAssertEqual(Just("Hello").removeDuplicates(), Just("Hello"))
        XCTAssertEqual(Just("Hello").removeDuplicates(by: { _, _ in false }), Just("Hello"))

        XCTAssertEqual(
            Just("Hello")
                .tryRemoveDuplicates(by: { _, _ in false })
                .mapError { $0 as! TestError },
            ResultPublisher("Hello")
        )
        XCTAssertEqual(
            Just("Hello")
                .tryRemoveDuplicates(by: { _, _ in throw TestError.error })
                .mapError { $0 as! TestError },
            ResultPublisher("Hello")
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
    }

    func testScan() {
        XCTAssertEqual(Just("Hello").scan(0) { $0 + $1.count }, ResultPublisher("Hello".count))

        XCTAssertEqual(
            Just("Hello")
                .tryScan(0) { $0 + $1.count }
                .mapError { $0 as! TestError },
            ResultPublisher("Hello".count)
        )
        XCTAssertEqual(
            Just("Hello")
                .tryScan(0) { _, _ in throw TestError.error }
                .mapError { $0 as! TestError },
            ResultPublisher(.error)
        )
    }
}
