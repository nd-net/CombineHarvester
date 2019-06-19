//
//  OnceTests.swift
//  CombineHarvesterTests
//
//  Created by Andreas Hartl on 19.06.19.
//

import XCTest
@testable import CombineHarvester

class OnceTests: XCTestCase {
    typealias TestOnce = Publishers.Once<String, TestError>

    func testSubscribe() {
        var subject = TestSubject<String, TestError>()
        var publisher = TestOnce("Hello")
        _ = publisher.subscribe(subject)

        XCTAssertEqual(subject.values, ["Hello"])
        XCTAssertEqual(subject.completion, [.finished])

        subject = TestSubject()
        publisher = Publishers.Once(Result.success("Hello"))
        _ = publisher.subscribe(subject)

        XCTAssertEqual(subject.values, ["Hello"])
        XCTAssertEqual(subject.completion, [.finished])

        subject = TestSubject()
        publisher = Publishers.Once(.error)
        _ = publisher.subscribe(subject)

        XCTAssertEqual(subject.values, [])
        XCTAssertEqual(subject.completion, [.failure(.error)])

        subject = TestSubject()
        publisher = Publishers.Once(Result.failure(.error))
        _ = publisher.subscribe(subject)

        XCTAssertEqual(subject.values, [])
        XCTAssertEqual(subject.completion, [.failure(.error)])
    }

    func testEquals() {
        XCTAssertEqual(TestOnce("Hello"), TestOnce("Hello"))
        XCTAssertEqual(TestOnce(.error), TestOnce(.error))
    }

    func testAllSatisfy() {
        XCTAssertEqual(TestOnce("Hello").allSatisfy { $0 == "Hello" }, Publishers.Once(true))
        XCTAssertEqual(TestOnce("Hello").allSatisfy { $0 != "Hello" }, Publishers.Once(false))
        XCTAssertEqual(TestOnce(.error).allSatisfy { _ in
            XCTFail()
            return true
        }, Publishers.Once(.error))

        XCTAssertEqual(
            TestOnce("Hello")
                .tryAllSatisfy { $0 == "Hello" }
                .mapError { $0 as! TestError },
            Publishers.Once(true)
        )
        XCTAssertEqual(
            TestOnce("Hello")
                .tryAllSatisfy { $0 != "Hello" }
                .mapError { $0 as! TestError },
            Publishers.Once(false)
        )
        XCTAssertEqual(
            TestOnce("Hello")
                .tryAllSatisfy { _ in throw TestError.error }
                .mapError { $0 as! TestError },
            Publishers.Once(TestError.error)
        )
        XCTAssertEqual(
            TestOnce(.error)
                .tryAllSatisfy { $0 == "Hello" }
                .mapError { $0 as! TestError },
            Publishers.Once(.error)
        )
        XCTAssertEqual(
            TestOnce(.error)
                .tryAllSatisfy { $0 != "Hello" }
                .mapError { $0 as! TestError },
            Publishers.Once(.error)
        )
        XCTAssertEqual(
            TestOnce(.error)
                .tryAllSatisfy { _ in throw TestError.otherError }
                .mapError { $0 as! TestError },
            Publishers.Once(.error)
        )
    }

    func testCollect() {
        XCTAssertEqual(TestOnce("Hello").collect(), Publishers.Once(["Hello"]))
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
        XCTAssertEqual(TestOnce("Hello").min(), Publishers.Once("Hello"))
        XCTAssertEqual(TestOnce("Hello").min(by: { _, _ in false }), Publishers.Once("Hello"))
        XCTAssertEqual(TestOnce(.error).min(), Publishers.Once(.error))
        XCTAssertEqual(TestOnce(.error).min(by: { _, _ in false }), Publishers.Once(.error))

        XCTAssertEqual(TestOnce("Hello").tryMin(by: { _, _ in throw TestError.error }), Publishers.Once("Hello"))
        XCTAssertEqual(TestOnce(.error).tryMin(by: { _, _ in throw TestError.otherError }), Publishers.Once(.error))
    }

    func testMax() {
        XCTAssertEqual(TestOnce("Hello").max(), Publishers.Once("Hello"))
        XCTAssertEqual(TestOnce("Hello").max(by: { _, _ in false }), Publishers.Once("Hello"))
        XCTAssertEqual(TestOnce(.error).max(), Publishers.Once(.error))
        XCTAssertEqual(TestOnce(.error).max(by: { _, _ in false }), Publishers.Once(.error))

        XCTAssertEqual(TestOnce("Hello").tryMax(by: { _, _ in throw TestError.otherError }), Publishers.Once("Hello"))
        XCTAssertEqual(TestOnce(.error).tryMax(by: { _, _ in throw TestError.otherError }), Publishers.Once(.error))
    }

    func testContains() {
        XCTAssertEqual(TestOnce("Hello").contains("Hello"), Publishers.Once(true))
        XCTAssertEqual(TestOnce("Hello").contains("Hi"), Publishers.Once(false))
        XCTAssertEqual(TestOnce(.error).contains("Hello"), Publishers.Once(.error))
        XCTAssertEqual(TestOnce(.error).contains("Hi"), Publishers.Once(.error))

        XCTAssertEqual(TestOnce("Hello").contains(where: { $0 == "Hello" }), Publishers.Once(true))
        XCTAssertEqual(TestOnce("Hello").contains(where: { $0 == "Hi" }), Publishers.Once(false))
        XCTAssertEqual(TestOnce(.error).contains(where: { $0 == "Hello" }), Publishers.Once(.error))
        XCTAssertEqual(TestOnce(.error).contains(where: { $0 == "Hi" }), Publishers.Once(.error))

        XCTAssertEqual(
            TestOnce("Hello")
                .tryContains(where: { $0 == "Hello" })
                .mapError { $0 as! TestError },
            Publishers.Once(true)
        )
        XCTAssertEqual(
            TestOnce("Hello")
                .tryContains(where: { $0 == "Hi" })
                .mapError { $0 as! TestError },
            Publishers.Once(false)
        )
        XCTAssertEqual(
            TestOnce("Hello")
                .tryContains(where: { _ in throw TestError.error })
                .mapError { $0 as! TestError },
            Publishers.Once(TestError.error)
        )
        XCTAssertEqual(
            TestOnce(.error)
                .tryContains(where: { $0 == "Hello" })
                .mapError { $0 as! TestError },
            Publishers.Once(.error)
        )
        XCTAssertEqual(
            TestOnce(.error)
                .tryContains(where: { $0 == "Hi" })
                .mapError { $0 as! TestError },
            Publishers.Once(.error)
        )
        XCTAssertEqual(
            TestOnce(.error)
                .tryContains(where: { _ in throw TestError.otherError })
                .mapError { $0 as! TestError },
            Publishers.Once(TestError.error)
        )
    }

    func testCount() {
        XCTAssertEqual(TestOnce("Hello").count(), Publishers.Once(1))
        XCTAssertEqual(TestOnce(.error).count(), Publishers.Once(.error))
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
        XCTAssertEqual(TestOnce("Hello").first(), Publishers.Once("Hello"))
        XCTAssertEqual(TestOnce(.error).first(), Publishers.Once(.error))

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
        XCTAssertEqual(TestOnce("Hello").last(), Publishers.Once("Hello"))
        XCTAssertEqual(TestOnce(.error).last(), Publishers.Once(.error))

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
        XCTAssertEqual(TestOnce("Hello").map { "!\($0)!" }, Publishers.Once("!Hello!"))
        XCTAssertEqual(TestOnce(.error).map { "!\($0)!" }, Publishers.Once(.error))

        XCTAssertEqual(
            TestOnce("Hello")
                .tryMap { "!\($0)!" }
                .mapError { $0 as! TestError },
            Publishers.Once("!Hello!")
        )
        XCTAssertEqual(
            TestOnce("Hello")
                .tryMap { (_) -> String in throw TestError.error }
                .mapError { $0 as! TestError },
            Publishers.Once(.error)
        )
        XCTAssertEqual(
            TestOnce(.error)
                .tryMap { "!\($0)!" }
                .mapError { $0 as! TestError },
            Publishers.Once(.error)
        )
        XCTAssertEqual(
            TestOnce(.error)
                .tryMap { (_) -> String in throw TestError.otherError }
                .mapError { $0 as! TestError },
            Publishers.Once(.error)
        )
    }

    func testMapError() {
        XCTAssertEqual(TestOnce("Hello").mapError { _ in TestError.error }, Publishers.Once("Hello"))
        XCTAssertEqual(TestOnce(.error).mapError { _ in TestError.otherError }, Publishers.Once(.otherError))
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
        XCTAssertEqual(TestOnce("Hello").reduce(0) { $0 + $1.count }, Publishers.Once("Hello".count))
        XCTAssertEqual(TestOnce(.error).reduce(0) { $0 + $1.count }, Publishers.Once(.error))

        XCTAssertEqual(
            TestOnce("Hello")
                .tryReduce(0) { $0 + $1.count }
                .mapError { $0 as! TestError },
            Publishers.Once("Hello".count)
        )
        XCTAssertEqual(
            TestOnce("Hello")
                .tryReduce(0) { _, _ in throw TestError.error }
                .mapError { $0 as! TestError },
            Publishers.Once(.error)
        )
        XCTAssertEqual(
            TestOnce(.error)
                .tryReduce(0) { $0 + $1.count }
                .mapError { $0 as! TestError },
            Publishers.Once(.error)
        )
        XCTAssertEqual(
            TestOnce(.error)
                .tryReduce(0) { _, _ in throw TestError.otherError }
                .mapError { $0 as! TestError },
            Publishers.Once(.error)
        )
    }

    func testRemoveDuplicates() {
        XCTAssertEqual(TestOnce("Hello").removeDuplicates(), Publishers.Once("Hello"))
        XCTAssertEqual(TestOnce("Hello").removeDuplicates(by: { _, _ in false }), Publishers.Once("Hello"))
        XCTAssertEqual(TestOnce(.error).removeDuplicates(), Publishers.Once(.error))
        XCTAssertEqual(TestOnce(.error).removeDuplicates(by: { _, _ in false }), Publishers.Once(.error))

        XCTAssertEqual(
            TestOnce("Hello")
                .tryRemoveDuplicates(by: { _, _ in false })
                .mapError { $0 as! TestError },
            Publishers.Once("Hello")
        )
        XCTAssertEqual(
            TestOnce("Hello")
                .tryRemoveDuplicates(by: { _, _ in throw TestError.error })
                .mapError { $0 as! TestError },
            Publishers.Once("Hello")
        )
        XCTAssertEqual(
            TestOnce(.error)
                .tryRemoveDuplicates(by: { _, _ in false })
                .mapError { $0 as! TestError },
            Publishers.Once(.error)
        )
        XCTAssertEqual(
            TestOnce(.error)
                .tryRemoveDuplicates(by: { _, _ in throw TestError.otherError })
                .mapError { $0 as! TestError },
            Publishers.Once(.error)
        )
    }

    func testReplaceError() {
        XCTAssertEqual(TestOnce("Hello").replaceError(with: "World"), Publishers.Once("Hello"))
        XCTAssertEqual(TestOnce(.error).replaceError(with: "World"), Publishers.Once("World"))
    }

    func testReplaceEmpty() {
        XCTAssertEqual(TestOnce("Hello").replaceEmpty(with: "World"), Publishers.Once("Hello"))
        XCTAssertEqual(TestOnce(.error).replaceEmpty(with: "World"), Publishers.Once(.error))
    }

    func testRetry() {
        XCTAssertEqual(TestOnce("Hello").retry(42), Publishers.Once("Hello"))
        XCTAssertEqual(TestOnce("Hello").retry(), Publishers.Once("Hello"))
        XCTAssertEqual(TestOnce(.error).retry(42), Publishers.Once(.error))
        XCTAssertEqual(TestOnce(.error).retry(), Publishers.Once(.error))
    }

    func testScan() {
        XCTAssertEqual(TestOnce("Hello").scan(0) { $0 + $1.count }, Publishers.Once("Hello".count))
        XCTAssertEqual(TestOnce(.error).scan(0) { $0 + $1.count }, Publishers.Once(.error))

        XCTAssertEqual(
            TestOnce("Hello")
                .tryScan(0) { $0 + $1.count }
                .mapError { $0 as! TestError },
            Publishers.Once("Hello".count)
        )
        XCTAssertEqual(
            TestOnce("Hello")
                .tryScan(0) { _, _ in throw TestError.error }
                .mapError { $0 as! TestError },
            Publishers.Once(.error)
        )
        XCTAssertEqual(
            TestOnce(.error)
                .tryScan(0) { $0 + $1.count }
                .mapError { $0 as! TestError },
            Publishers.Once(.error)
        )
        XCTAssertEqual(
            TestOnce(.error)
                .tryScan(0) { _, _ in throw TestError.otherError }
                .mapError { $0 as! TestError },
            Publishers.Once(.error)
        )
    }
}
