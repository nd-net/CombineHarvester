//
//  ResultPublisherTests.swift
//  CombineHarvesterTests
//
//  Created by Andreas Hartl on 19.06.19.
//

import XCTest
@testable import CombineHarvester

class ResultPublisherTests: XCTestCase {
    typealias ResultPublisher<Output, E: Error> = Result<Output, E>.ResultPublisher
    typealias TestOnce = ResultPublisher<String, TestError>

    func testSubscribe() {
        var subject = TestSubject<String, TestError>()
        var publisher = TestOnce("Hello")
        _ = publisher.subscribe(subject)

        XCTAssertEqual(subject.values, ["Hello"])
        XCTAssertEqual(subject.completion, [.finished])

        subject = TestSubject()
        publisher = ResultPublisher(Result.success("Hello"))
        _ = publisher.subscribe(subject)

        XCTAssertEqual(subject.values, ["Hello"])
        XCTAssertEqual(subject.completion, [.finished])

        subject = TestSubject()
        publisher = ResultPublisher(.error)
        _ = publisher.subscribe(subject)

        XCTAssertEqual(subject.values, [])
        XCTAssertEqual(subject.completion, [.failure(.error)])

        subject = TestSubject()
        publisher = ResultPublisher(Result.failure(.error))
        _ = publisher.subscribe(subject)

        XCTAssertEqual(subject.values, [])
        XCTAssertEqual(subject.completion, [.failure(.error)])
    }

    func testEquals() {
        XCTAssertEqual(TestOnce("Hello"), TestOnce("Hello"))
        XCTAssertEqual(TestOnce(.error), TestOnce(.error))
    }

    func testAllSatisfy() {
        XCTAssertEqual(TestOnce("Hello").allSatisfy { $0 == "Hello" }, ResultPublisher(true))
        XCTAssertEqual(TestOnce("Hello").allSatisfy { $0 != "Hello" }, ResultPublisher(false))
        XCTAssertEqual(TestOnce(.error).allSatisfy { _ in
            XCTFail()
            return true
        }, ResultPublisher(.error))

        XCTAssertEqual(
            TestOnce("Hello")
                .tryAllSatisfy { $0 == "Hello" }
                .mapError { $0 as! TestError },
            ResultPublisher(true)
        )
        XCTAssertEqual(
            TestOnce("Hello")
                .tryAllSatisfy { $0 != "Hello" }
                .mapError { $0 as! TestError },
            ResultPublisher(false)
        )
        XCTAssertEqual(
            TestOnce("Hello")
                .tryAllSatisfy { _ in throw TestError.error }
                .mapError { $0 as! TestError },
            ResultPublisher(TestError.error)
        )
        XCTAssertEqual(
            TestOnce(.error)
                .tryAllSatisfy { $0 == "Hello" }
                .mapError { $0 as! TestError },
            ResultPublisher(.error)
        )
        XCTAssertEqual(
            TestOnce(.error)
                .tryAllSatisfy { $0 != "Hello" }
                .mapError { $0 as! TestError },
            ResultPublisher(.error)
        )
        XCTAssertEqual(
            TestOnce(.error)
                .tryAllSatisfy { _ in throw TestError.otherError }
                .mapError { $0 as! TestError },
            ResultPublisher(.error)
        )
    }

    func testCollect() {
        XCTAssertEqual(TestOnce("Hello").collect(), ResultPublisher(["Hello"]))
    }

    func testCompactMap() {
        XCTAssertEqual(TestOnce("Hello").compactMap { $0 }, Publishers.Optional("Hello"))
        XCTAssertEqual(TestOnce("Hello").compactMap { _ -> Int? in nil }, Publishers.Optional(nil))
        XCTAssertEqual(TestOnce(.error).compactMap { $0 }, Publishers.Optional(.error))
        XCTAssertEqual(TestOnce(.error).compactMap { _ -> Int? in nil }, Publishers.Optional(.error))

        XCTAssertEqual(
            TestOnce("Hello")
                .tryCompactMap { $0 }
                .mapError { $0 as! TestError },
            Publishers.Optional("Hello")
        )
        XCTAssertEqual(
            TestOnce("Hello")
                .tryCompactMap { _ -> Int? in nil }
                .mapError { $0 as! TestError },
            Publishers.Optional(nil)
        )
        XCTAssertEqual(
            TestOnce("Hello")
                .tryCompactMap { _ -> Int? in throw TestError.error }
                .mapError { $0 as! TestError },
            Publishers.Optional(.error)
        )
        XCTAssertEqual(
            TestOnce(.error)
                .tryCompactMap { $0 }
                .mapError { $0 as! TestError },
            Publishers.Optional(.error)
        )
        XCTAssertEqual(
            TestOnce(.error)
                .tryCompactMap { _ -> Int? in nil }
                .mapError { $0 as! TestError },
            Publishers.Optional(.error)
        )
        XCTAssertEqual(
            TestOnce(.error)
                .tryCompactMap { _ -> Int? in throw TestError.otherError }
                .mapError { $0 as! TestError },
            Publishers.Optional(.error)
        )
    }

    func testMin() {
        XCTAssertEqual(TestOnce("Hello").min(), ResultPublisher("Hello"))
        XCTAssertEqual(TestOnce("Hello").min(by: { _, _ in false }), ResultPublisher("Hello"))
        XCTAssertEqual(TestOnce(.error).min(), ResultPublisher(.error))
        XCTAssertEqual(TestOnce(.error).min(by: { _, _ in false }), ResultPublisher(.error))

        XCTAssertEqual(TestOnce("Hello").tryMin(by: { _, _ in throw TestError.error }), ResultPublisher("Hello"))
        XCTAssertEqual(TestOnce(.error).tryMin(by: { _, _ in throw TestError.otherError }), ResultPublisher(.error))
    }

    func testMax() {
        XCTAssertEqual(TestOnce("Hello").max(), ResultPublisher("Hello"))
        XCTAssertEqual(TestOnce("Hello").max(by: { _, _ in false }), ResultPublisher("Hello"))
        XCTAssertEqual(TestOnce(.error).max(), ResultPublisher(.error))
        XCTAssertEqual(TestOnce(.error).max(by: { _, _ in false }), ResultPublisher(.error))

        XCTAssertEqual(TestOnce("Hello").tryMax(by: { _, _ in throw TestError.otherError }), ResultPublisher("Hello"))
        XCTAssertEqual(TestOnce(.error).tryMax(by: { _, _ in throw TestError.otherError }), ResultPublisher(.error))
    }

    func testContains() {
        XCTAssertEqual(TestOnce("Hello").contains("Hello"), ResultPublisher(true))
        XCTAssertEqual(TestOnce("Hello").contains("Hi"), ResultPublisher(false))
        XCTAssertEqual(TestOnce(.error).contains("Hello"), ResultPublisher(.error))
        XCTAssertEqual(TestOnce(.error).contains("Hi"), ResultPublisher(.error))

        XCTAssertEqual(TestOnce("Hello").contains(where: { $0 == "Hello" }), ResultPublisher(true))
        XCTAssertEqual(TestOnce("Hello").contains(where: { $0 == "Hi" }), ResultPublisher(false))
        XCTAssertEqual(TestOnce(.error).contains(where: { $0 == "Hello" }), ResultPublisher(.error))
        XCTAssertEqual(TestOnce(.error).contains(where: { $0 == "Hi" }), ResultPublisher(.error))

        XCTAssertEqual(
            TestOnce("Hello")
                .tryContains(where: { $0 == "Hello" })
                .mapError { $0 as! TestError },
            ResultPublisher(true)
        )
        XCTAssertEqual(
            TestOnce("Hello")
                .tryContains(where: { $0 == "Hi" })
                .mapError { $0 as! TestError },
            ResultPublisher(false)
        )
        XCTAssertEqual(
            TestOnce("Hello")
                .tryContains(where: { _ in throw TestError.error })
                .mapError { $0 as! TestError },
            ResultPublisher(TestError.error)
        )
        XCTAssertEqual(
            TestOnce(.error)
                .tryContains(where: { $0 == "Hello" })
                .mapError { $0 as! TestError },
            ResultPublisher(.error)
        )
        XCTAssertEqual(
            TestOnce(.error)
                .tryContains(where: { $0 == "Hi" })
                .mapError { $0 as! TestError },
            ResultPublisher(.error)
        )
        XCTAssertEqual(
            TestOnce(.error)
                .tryContains(where: { _ in throw TestError.otherError })
                .mapError { $0 as! TestError },
            ResultPublisher(TestError.error)
        )
    }

    func testCount() {
        XCTAssertEqual(TestOnce("Hello").count(), ResultPublisher(1))
        XCTAssertEqual(TestOnce(.error).count(), ResultPublisher(.error))
    }

    func testDrop() {
        XCTAssertEqual(TestOnce("Hello").dropFirst(), Publishers.Optional(nil))
        XCTAssertEqual(TestOnce("Hello").dropFirst(0), Publishers.Optional("Hello"))
        XCTAssertEqual(TestOnce(.error).dropFirst(), Publishers.Optional(.error))
        XCTAssertEqual(TestOnce(.error).dropFirst(0), Publishers.Optional(.error))

        XCTAssertEqual(TestOnce("Hello").drop { $0 == "Hello" }, Publishers.Optional(nil))
        XCTAssertEqual(TestOnce("Hello").drop { $0 != "Hello" }, Publishers.Optional("Hello"))
        XCTAssertEqual(TestOnce(.error).drop { $0 == "Hello" }, Publishers.Optional(.error))
        XCTAssertEqual(TestOnce(.error).drop { $0 != "Hello" }, Publishers.Optional(.error))

        XCTAssertEqual(
            TestOnce("Hello")
                .tryDrop { $0 == "Hello" }
                .mapError { $0 as! TestError },
            Publishers.Optional(nil)
        )
        XCTAssertEqual(
            TestOnce("Hello")
                .tryDrop { $0 != "Hello" }
                .mapError { $0 as! TestError },
            Publishers.Optional("Hello")
        )
        XCTAssertEqual(
            TestOnce("Hello")
                .tryDrop { _ in throw TestError.error }
                .mapError { $0 as! TestError },
            Publishers.Optional(.error)
        )
        XCTAssertEqual(
            TestOnce(.error)
                .tryDrop { $0 == "Hello" }
                .mapError { $0 as! TestError },
            Publishers.Optional(.error)
        )
        XCTAssertEqual(
            TestOnce(.error)
                .tryDrop { $0 != "Hello" }
                .mapError { $0 as! TestError },
            Publishers.Optional(.error)
        )
        XCTAssertEqual(
            TestOnce(.error)
                .tryDrop { _ in throw TestError.otherError }
                .mapError { $0 as! TestError },
            Publishers.Optional(.error)
        )
    }

    func testFirst() {
        XCTAssertEqual(TestOnce("Hello").first(), ResultPublisher("Hello"))
        XCTAssertEqual(TestOnce(.error).first(), ResultPublisher(.error))

        XCTAssertEqual(TestOnce("Hello").first { $0 == "Hello" }, Publishers.Optional("Hello"))
        XCTAssertEqual(TestOnce("Hello").first { $0 != "Hello" }, Publishers.Optional(nil))
        XCTAssertEqual(TestOnce(.error).first { $0 == "Hello" }, Publishers.Optional(.error))
        XCTAssertEqual(TestOnce(.error).first { $0 != "Hello" }, Publishers.Optional(.error))

        XCTAssertEqual(
            TestOnce("Hello")
                .tryFirst { $0 == "Hello" }
                .mapError { $0 as! TestError },
            Publishers.Optional("Hello")
        )
        XCTAssertEqual(
            TestOnce("Hello")
                .tryFirst { $0 != "Hello" }
                .mapError { $0 as! TestError },
            Publishers.Optional(nil)
        )
        XCTAssertEqual(
            TestOnce("Hello")
                .tryFirst { _ in throw TestError.error }
                .mapError { $0 as! TestError },
            Publishers.Optional(.error)
        )
        XCTAssertEqual(
            TestOnce(.error)
                .tryFirst { $0 == "Hello" }
                .mapError { $0 as! TestError },
            Publishers.Optional(.error)
        )
        XCTAssertEqual(
            TestOnce(.error)
                .tryFirst { $0 != "Hello" }
                .mapError { $0 as! TestError },
            Publishers.Optional(.error)
        )
        XCTAssertEqual(
            TestOnce(.error)
                .tryFirst { _ in throw TestError.otherError }
                .mapError { $0 as! TestError },
            Publishers.Optional(.error)
        )
    }

    func testLast() {
        XCTAssertEqual(TestOnce("Hello").last(), ResultPublisher("Hello"))
        XCTAssertEqual(TestOnce(.error).last(), ResultPublisher(.error))

        XCTAssertEqual(TestOnce("Hello").last { $0 == "Hello" }, Publishers.Optional("Hello"))
        XCTAssertEqual(TestOnce("Hello").last { $0 != "Hello" }, Publishers.Optional(nil))
        XCTAssertEqual(TestOnce(.error).last { $0 == "Hello" }, Publishers.Optional(.error))
        XCTAssertEqual(TestOnce(.error).last { $0 != "Hello" }, Publishers.Optional(.error))

        XCTAssertEqual(
            TestOnce("Hello")
                .tryLast { $0 == "Hello" }
                .mapError { $0 as! TestError },
            Publishers.Optional("Hello")
        )
        XCTAssertEqual(
            TestOnce("Hello")
                .tryLast { $0 != "Hello" }
                .mapError { $0 as! TestError },
            Publishers.Optional(nil)
        )
        XCTAssertEqual(
            TestOnce("Hello")
                .tryLast { _ in throw TestError.error }
                .mapError { $0 as! TestError },
            Publishers.Optional(.error)
        )
        XCTAssertEqual(
            TestOnce(.error)
                .tryLast { $0 == "Hello" }
                .mapError { $0 as! TestError },
            Publishers.Optional(.error)
        )
        XCTAssertEqual(
            TestOnce(.error)
                .tryLast { $0 != "Hello" }
                .mapError { $0 as! TestError },
            Publishers.Optional(.error)
        )
        XCTAssertEqual(
            TestOnce(.error)
                .tryLast { _ in throw TestError.otherError }
                .mapError { $0 as! TestError },
            Publishers.Optional(.error)
        )
    }

    func testFilter() {
        XCTAssertEqual(TestOnce("Hello").filter { $0 == "Hello" }, Publishers.Optional("Hello"))
        XCTAssertEqual(TestOnce("Hello").filter { $0 != "Hello" }, Publishers.Optional(nil))
        XCTAssertEqual(TestOnce(.error).filter { $0 == "Hello" }, Publishers.Optional(.error))
        XCTAssertEqual(TestOnce(.error).filter { $0 != "Hello" }, Publishers.Optional(.error))

        XCTAssertEqual(
            TestOnce("Hello")
                .tryFilter { $0 == "Hello" }
                .mapError { $0 as! TestError },
            Publishers.Optional("Hello")
        )
        XCTAssertEqual(
            TestOnce("Hello")
                .tryFilter { $0 != "Hello" }
                .mapError { $0 as! TestError },
            Publishers.Optional(nil)
        )
        XCTAssertEqual(
            TestOnce("Hello")
                .tryFilter { _ in throw TestError.error }
                .mapError { $0 as! TestError },
            Publishers.Optional(.error)
        )
        XCTAssertEqual(
            TestOnce(.error)
                .tryFilter { $0 == "Hello" }
                .mapError { $0 as! TestError },
            Publishers.Optional(.error)
        )
        XCTAssertEqual(
            TestOnce(.error)
                .tryLast { $0 != "Hello" }
                .mapError { $0 as! TestError },
            Publishers.Optional(.error)
        )
        XCTAssertEqual(
            TestOnce(.error)
                .tryLast { _ in throw TestError.otherError }
                .mapError { $0 as! TestError },
            Publishers.Optional(.error)
        )
    }

    func testIgnoreOutput() {
        XCTAssertEqual(TestOnce("Hello").ignoreOutput(), Publishers.Empty())
        XCTAssertEqual(TestOnce(.error).ignoreOutput(), Publishers.Empty())
    }

    func testMap() {
        XCTAssertEqual(TestOnce("Hello").map { "!\($0)!" }, ResultPublisher("!Hello!"))
        XCTAssertEqual(TestOnce(.error).map { "!\($0)!" }, ResultPublisher(.error))

        XCTAssertEqual(
            TestOnce("Hello")
                .tryMap { "!\($0)!" }
                .mapError { $0 as! TestError },
            ResultPublisher("!Hello!")
        )
        XCTAssertEqual(
            TestOnce("Hello")
                .tryMap { (_) -> String in throw TestError.error }
                .mapError { $0 as! TestError },
            ResultPublisher(.error)
        )
        XCTAssertEqual(
            TestOnce(.error)
                .tryMap { "!\($0)!" }
                .mapError { $0 as! TestError },
            ResultPublisher(.error)
        )
        XCTAssertEqual(
            TestOnce(.error)
                .tryMap { (_) -> String in throw TestError.otherError }
                .mapError { $0 as! TestError },
            ResultPublisher(.error)
        )
    }

    func testMapError() {
        XCTAssertEqual(TestOnce("Hello").mapError { _ in TestError.error }, ResultPublisher("Hello"))
        XCTAssertEqual(TestOnce(.error).mapError { _ in TestError.otherError }, ResultPublisher(.otherError))
    }

    func testOutput() {
        XCTAssertEqual(TestOnce("Hello").output(at: 0), Publishers.Optional("Hello"))
        XCTAssertEqual(TestOnce("Hello").output(at: 1), Publishers.Optional(nil))
        XCTAssertEqual(TestOnce(.error).output(at: 0), Publishers.Optional(.error))
        XCTAssertEqual(TestOnce(.error).output(at: 1), Publishers.Optional(.error))

        XCTAssertEqual(TestOnce("Hello").output(in: ...1), Publishers.Optional("Hello"))
        XCTAssertEqual(TestOnce("Hello").output(in: 1...), Publishers.Optional(nil))
        XCTAssertEqual(TestOnce(.error).output(in: ...1), Publishers.Optional(.error))
        XCTAssertEqual(TestOnce(.error).output(in: 1...), Publishers.Optional(.error))
    }

    func testPrefix() {
        XCTAssertEqual(TestOnce("Hello").prefix(0), Publishers.Optional(nil))
        XCTAssertEqual(TestOnce("Hello").prefix(1), Publishers.Optional("Hello"))
        XCTAssertEqual(TestOnce(.error).prefix(0), Publishers.Optional(.error))
        XCTAssertEqual(TestOnce(.error).prefix(1), Publishers.Optional(.error))

        XCTAssertEqual(TestOnce("Hello").prefix(while: { $0 == "Hello" }), Publishers.Optional("Hello"))
        XCTAssertEqual(TestOnce("Hello").prefix(while: { $0 != "Hello" }), Publishers.Optional(nil))
        XCTAssertEqual(TestOnce(.error).prefix(while: { $0 == "Hello" }), Publishers.Optional(.error))
        XCTAssertEqual(TestOnce(.error).prefix(while: { $0 != "Hello" }), Publishers.Optional(.error))

        XCTAssertEqual(
            TestOnce("Hello")
                .tryPrefix(while: { $0 == "Hello" })
                .mapError { $0 as! TestError },
            Publishers.Optional("Hello")
        )
        XCTAssertEqual(
            TestOnce("Hello")
                .tryPrefix(while: { $0 != "Hello" })
                .mapError { $0 as! TestError },
            Publishers.Optional(nil)
        )
        XCTAssertEqual(
            TestOnce("Hello")
                .tryPrefix(while: { _ in throw TestError.error })
                .mapError { $0 as! TestError },
            Publishers.Optional(.error)
        )
        XCTAssertEqual(
            TestOnce(.error)
                .tryPrefix(while: { $0 == "Hello" })
                .mapError { $0 as! TestError },
            Publishers.Optional(.error)
        )
        XCTAssertEqual(
            TestOnce(.error)
                .tryPrefix(while: { $0 != "Hello" })
                .mapError { $0 as! TestError },
            Publishers.Optional(.error)
        )
        XCTAssertEqual(
            TestOnce(.error)
                .tryPrefix(while: { _ in throw TestError.otherError })
                .mapError { $0 as! TestError },
            Publishers.Optional(.error)
        )
    }

    func testReduce() {
        XCTAssertEqual(TestOnce("Hello").reduce(0) { $0 + $1.count }, ResultPublisher("Hello".count))
        XCTAssertEqual(TestOnce(.error).reduce(0) { $0 + $1.count }, ResultPublisher(.error))

        XCTAssertEqual(
            TestOnce("Hello")
                .tryReduce(0) { $0 + $1.count }
                .mapError { $0 as! TestError },
            ResultPublisher("Hello".count)
        )
        XCTAssertEqual(
            TestOnce("Hello")
                .tryReduce(0) { _, _ in throw TestError.error }
                .mapError { $0 as! TestError },
            ResultPublisher(.error)
        )
        XCTAssertEqual(
            TestOnce(.error)
                .tryReduce(0) { $0 + $1.count }
                .mapError { $0 as! TestError },
            ResultPublisher(.error)
        )
        XCTAssertEqual(
            TestOnce(.error)
                .tryReduce(0) { _, _ in throw TestError.otherError }
                .mapError { $0 as! TestError },
            ResultPublisher(.error)
        )
    }

    func testRemoveDuplicates() {
        XCTAssertEqual(TestOnce("Hello").removeDuplicates(), ResultPublisher("Hello"))
        XCTAssertEqual(TestOnce("Hello").removeDuplicates(by: { _, _ in false }), ResultPublisher("Hello"))
        XCTAssertEqual(TestOnce(.error).removeDuplicates(), ResultPublisher(.error))
        XCTAssertEqual(TestOnce(.error).removeDuplicates(by: { _, _ in false }), ResultPublisher(.error))

        XCTAssertEqual(
            TestOnce("Hello")
                .tryRemoveDuplicates(by: { _, _ in false })
                .mapError { $0 as! TestError },
            ResultPublisher("Hello")
        )
        XCTAssertEqual(
            TestOnce("Hello")
                .tryRemoveDuplicates(by: { _, _ in throw TestError.error })
                .mapError { $0 as! TestError },
            ResultPublisher("Hello")
        )
        XCTAssertEqual(
            TestOnce(.error)
                .tryRemoveDuplicates(by: { _, _ in false })
                .mapError { $0 as! TestError },
            ResultPublisher(.error)
        )
        XCTAssertEqual(
            TestOnce(.error)
                .tryRemoveDuplicates(by: { _, _ in throw TestError.otherError })
                .mapError { $0 as! TestError },
            ResultPublisher(.error)
        )
    }

    func testReplaceError() {
        XCTAssertEqual(TestOnce("Hello").replaceError(with: "World"), ResultPublisher("Hello"))
        XCTAssertEqual(TestOnce(.error).replaceError(with: "World"), ResultPublisher("World"))
    }

    func testReplaceEmpty() {
        XCTAssertEqual(TestOnce("Hello").replaceEmpty(with: "World"), ResultPublisher("Hello"))
        XCTAssertEqual(TestOnce(.error).replaceEmpty(with: "World"), ResultPublisher(.error))
    }

    func testRetry() {
        XCTAssertEqual(TestOnce("Hello").retry(42), ResultPublisher("Hello"))
        XCTAssertEqual(TestOnce("Hello").retry(), ResultPublisher("Hello"))
        XCTAssertEqual(TestOnce(.error).retry(42), ResultPublisher(.error))
        XCTAssertEqual(TestOnce(.error).retry(), ResultPublisher(.error))
    }

    func testScan() {
        XCTAssertEqual(TestOnce("Hello").scan(0) { $0 + $1.count }, ResultPublisher("Hello".count))
        XCTAssertEqual(TestOnce(.error).scan(0) { $0 + $1.count }, ResultPublisher(.error))

        XCTAssertEqual(
            TestOnce("Hello")
                .tryScan(0) { $0 + $1.count }
                .mapError { $0 as! TestError },
            ResultPublisher("Hello".count)
        )
        XCTAssertEqual(
            TestOnce("Hello")
                .tryScan(0) { _, _ in throw TestError.error }
                .mapError { $0 as! TestError },
            ResultPublisher(.error)
        )
        XCTAssertEqual(
            TestOnce(.error)
                .tryScan(0) { $0 + $1.count }
                .mapError { $0 as! TestError },
            ResultPublisher(.error)
        )
        XCTAssertEqual(
            TestOnce(.error)
                .tryScan(0) { _, _ in throw TestError.otherError }
                .mapError { $0 as! TestError },
            ResultPublisher(.error)
        )
    }
}
