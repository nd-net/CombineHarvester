//
//  OptionalTests.swift
//  CombineHarvesterTests
//
//  Created by Andreas Hartl on 19.06.19.
//

import XCTest
@testable import CombineHarvester

class OptionalTests: XCTestCase {
    // swiftformat:disable:next typeSugar
    typealias PublishersOptional = Publishers.Optional
    typealias TestOptional = PublishersOptional<String, TestError>

    func testSubscribe() {
        var subject = TestSubject<String, TestError>()
        var publisher = TestOptional("Hello")
        _ = publisher.subscribe(subject)

        XCTAssertEqual(subject.values, ["Hello"])
        XCTAssertEqual(subject.completion, [.finished])

        subject = TestSubject()
        publisher = PublishersOptional(nil)
        _ = publisher.subscribe(subject)

        XCTAssertEqual(subject.values, [])
        XCTAssertEqual(subject.completion, [.finished])

        subject = TestSubject()
        publisher = PublishersOptional(Result.success("Hello"))
        _ = publisher.subscribe(subject)

        XCTAssertEqual(subject.values, ["Hello"])
        XCTAssertEqual(subject.completion, [.finished])

        subject = TestSubject()
        publisher = PublishersOptional(Result.success(nil))
        _ = publisher.subscribe(subject)

        XCTAssertEqual(subject.values, [])
        XCTAssertEqual(subject.completion, [.finished])

        subject = TestSubject()
        publisher = PublishersOptional(.error)
        _ = publisher.subscribe(subject)

        XCTAssertEqual(subject.values, [])
        XCTAssertEqual(subject.completion, [.failure(.error)])

        subject = TestSubject()
        publisher = PublishersOptional(Result.failure(.error))
        _ = publisher.subscribe(subject)

        XCTAssertEqual(subject.values, [])
        XCTAssertEqual(subject.completion, [.failure(.error)])
    }

    func testEquals() {
        XCTAssertEqual(TestOptional("Hello"), TestOptional("Hello"))
        XCTAssertEqual(TestOptional(nil), TestOptional(nil))
        XCTAssertEqual(TestOptional(.error), TestOptional(.error))
    }

    func testAllSatisfy() {
        XCTAssertEqual(TestOptional(nil).allSatisfy { $0 == "Hello" }, PublishersOptional(nil))
        XCTAssertEqual(TestOptional("Hello").allSatisfy { $0 == "Hello" }, PublishersOptional(true))
        XCTAssertEqual(TestOptional("Hello").allSatisfy { $0 != "Hello" }, PublishersOptional(false))
        XCTAssertEqual(TestOptional(.error).allSatisfy { _ in
            XCTFail()
            return true
        }, PublishersOptional(.error))

        XCTAssertEqual(
            TestOptional(nil)
                .tryAllSatisfy { $0 == "Hello" }
                .mapError { $0 as! TestError },
            PublishersOptional(nil)
        )
        XCTAssertEqual(
            TestOptional(nil)
                .tryAllSatisfy { _ in throw TestError.error }
                .mapError { $0 as! TestError },
            PublishersOptional(nil)
        )
        XCTAssertEqual(
            TestOptional("Hello")
                .tryAllSatisfy { $0 == "Hello" }
                .mapError { $0 as! TestError },
            PublishersOptional(true)
        )
        XCTAssertEqual(
            TestOptional("Hello")
                .tryAllSatisfy { $0 != "Hello" }
                .mapError { $0 as! TestError },
            PublishersOptional(false)
        )
        XCTAssertEqual(
            TestOptional("Hello")
                .tryAllSatisfy { _ in throw TestError.error }
                .mapError { $0 as! TestError },
            PublishersOptional(TestError.error)
        )
        XCTAssertEqual(
            TestOptional(.error)
                .tryAllSatisfy { $0 == "Hello" }
                .mapError { $0 as! TestError },
            PublishersOptional(.error)
        )
        XCTAssertEqual(
            TestOptional(.error)
                .tryAllSatisfy { $0 != "Hello" }
                .mapError { $0 as! TestError },
            PublishersOptional(.error)
        )
        XCTAssertEqual(
            TestOptional(.error)
                .tryAllSatisfy { _ in throw TestError.otherError }
                .mapError { $0 as! TestError },
            PublishersOptional(.error)
        )
    }

    func testCollect() {
        XCTAssertEqual(TestOptional(nil).collect(), PublishersOptional(nil))
        XCTAssertEqual(TestOptional("Hello").collect(), PublishersOptional(["Hello"]))
    }

    func testCompactMap() {
        XCTAssertEqual(TestOptional(nil).compactMap { $0 }, PublishersOptional(nil))
        XCTAssertEqual(TestOptional("Hello").compactMap { $0 }, PublishersOptional("Hello"))
        XCTAssertEqual(TestOptional("Hello").compactMap { _ -> Int? in nil }, PublishersOptional(nil))
        XCTAssertEqual(TestOptional(.error).compactMap { $0 }, PublishersOptional(.error))
        XCTAssertEqual(TestOptional(.error).compactMap { _ -> Int? in nil }, PublishersOptional(.error))

        XCTAssertEqual(
            TestOptional(nil)
                .tryCompactMap { $0 }
                .mapError { $0 as! TestError },
            PublishersOptional(nil)
        )
        XCTAssertEqual(
            TestOptional(nil)
                .tryCompactMap { _ -> Int? in throw TestError.error }
                .mapError { $0 as! TestError },
            PublishersOptional(nil)
        )
        XCTAssertEqual(
            TestOptional("Hello")
                .tryCompactMap { $0 }
                .mapError { $0 as! TestError },
            PublishersOptional("Hello")
        )
        XCTAssertEqual(
            TestOptional("Hello")
                .tryCompactMap { _ -> Int? in nil }
                .mapError { $0 as! TestError },
            PublishersOptional(nil)
        )
        XCTAssertEqual(
            TestOptional("Hello")
                .tryCompactMap { _ -> Int? in throw TestError.error }
                .mapError { $0 as! TestError },
            PublishersOptional(.error)
        )
        XCTAssertEqual(
            TestOptional(.error)
                .tryCompactMap { $0 }
                .mapError { $0 as! TestError },
            PublishersOptional(.error)
        )
        XCTAssertEqual(
            TestOptional(.error)
                .tryCompactMap { _ -> Int? in nil }
                .mapError { $0 as! TestError },
            PublishersOptional(.error)
        )
        XCTAssertEqual(
            TestOptional(.error)
                .tryCompactMap { _ -> Int? in throw TestError.otherError }
                .mapError { $0 as! TestError },
            PublishersOptional(.error)
        )
    }

    func testMin() {
        XCTAssertEqual(TestOptional(nil).min(), PublishersOptional(nil))
        XCTAssertEqual(TestOptional(nil).min(by: { _, _ in false }), PublishersOptional(nil))
        XCTAssertEqual(TestOptional("Hello").min(), PublishersOptional("Hello"))
        XCTAssertEqual(TestOptional("Hello").min(by: { _, _ in false }), PublishersOptional("Hello"))
        XCTAssertEqual(TestOptional(.error).min(), PublishersOptional(.error))
        XCTAssertEqual(TestOptional(.error).min(by: { _, _ in false }), PublishersOptional(.error))

        XCTAssertEqual(TestOptional(nil).tryMin(by: { _, _ in throw TestError.error }), PublishersOptional(nil))
        XCTAssertEqual(TestOptional("Hello").tryMin(by: { _, _ in throw TestError.error }), PublishersOptional("Hello"))
        XCTAssertEqual(TestOptional(.error).tryMin(by: { _, _ in throw TestError.otherError }), PublishersOptional(.error))
    }

    func testMax() {
        XCTAssertEqual(TestOptional(nil).max(), PublishersOptional(nil))
        XCTAssertEqual(TestOptional(nil).max(by: { _, _ in false }), PublishersOptional(nil))
        XCTAssertEqual(TestOptional("Hello").max(), PublishersOptional("Hello"))
        XCTAssertEqual(TestOptional("Hello").max(by: { _, _ in false }), PublishersOptional("Hello"))
        XCTAssertEqual(TestOptional(.error).max(), PublishersOptional(.error))
        XCTAssertEqual(TestOptional(.error).max(by: { _, _ in false }), PublishersOptional(.error))

        XCTAssertEqual(TestOptional(nil).tryMax(by: { _, _ in throw TestError.otherError }), PublishersOptional(nil))
        XCTAssertEqual(TestOptional("Hello").tryMax(by: { _, _ in throw TestError.otherError }), PublishersOptional("Hello"))
        XCTAssertEqual(TestOptional(.error).tryMax(by: { _, _ in throw TestError.otherError }), PublishersOptional(.error))
    }

    func testContains() {
        XCTAssertEqual(TestOptional(nil).contains("Hello"), PublishersOptional(nil))
        XCTAssertEqual(TestOptional("Hello").contains("Hello"), PublishersOptional(true))
        XCTAssertEqual(TestOptional("Hello").contains("Hi"), PublishersOptional(false))
        XCTAssertEqual(TestOptional(.error).contains("Hello"), PublishersOptional(.error))
        XCTAssertEqual(TestOptional(.error).contains("Hi"), PublishersOptional(.error))

        XCTAssertEqual(TestOptional(nil).contains(where: { $0 == "Hello" }), PublishersOptional(nil))
        XCTAssertEqual(TestOptional("Hello").contains(where: { $0 == "Hello" }), PublishersOptional(true))
        XCTAssertEqual(TestOptional("Hello").contains(where: { $0 == "Hi" }), PublishersOptional(false))
        XCTAssertEqual(TestOptional(.error).contains(where: { $0 == "Hello" }), PublishersOptional(.error))
        XCTAssertEqual(TestOptional(.error).contains(where: { $0 == "Hi" }), PublishersOptional(.error))

        XCTAssertEqual(
            TestOptional(nil)
                .tryContains(where: { $0 == "Hello" })
                .mapError { $0 as! TestError },
            PublishersOptional(nil)
        )
        XCTAssertEqual(
            TestOptional(nil)
                .tryContains(where: { _ in throw TestError.error })
                .mapError { $0 as! TestError },
            PublishersOptional(nil)
        )
        XCTAssertEqual(
            TestOptional("Hello")
                .tryContains(where: { $0 == "Hello" })
                .mapError { $0 as! TestError },
            PublishersOptional(true)
        )
        XCTAssertEqual(
            TestOptional("Hello")
                .tryContains(where: { $0 == "Hi" })
                .mapError { $0 as! TestError },
            PublishersOptional(false)
        )
        XCTAssertEqual(
            TestOptional("Hello")
                .tryContains(where: { _ in throw TestError.error })
                .mapError { $0 as! TestError },
            PublishersOptional(TestError.error)
        )
        XCTAssertEqual(
            TestOptional(.error)
                .tryContains(where: { $0 == "Hello" })
                .mapError { $0 as! TestError },
            PublishersOptional(.error)
        )
        XCTAssertEqual(
            TestOptional(.error)
                .tryContains(where: { $0 == "Hi" })
                .mapError { $0 as! TestError },
            PublishersOptional(.error)
        )
        XCTAssertEqual(
            TestOptional(.error)
                .tryContains(where: { _ in throw TestError.otherError })
                .mapError { $0 as! TestError },
            PublishersOptional(TestError.error)
        )
    }

    func testCount() {
        XCTAssertEqual(TestOptional(nil).count(), PublishersOptional(0))
        XCTAssertEqual(TestOptional("Hello").count(), PublishersOptional(1))
        XCTAssertEqual(TestOptional(.error).count(), PublishersOptional(.error))
    }

    func testDrop() {
        XCTAssertEqual(TestOptional(nil).dropFirst(), PublishersOptional(nil))
        XCTAssertEqual(TestOptional("Hello").dropFirst(), PublishersOptional(nil))
        XCTAssertEqual(TestOptional("Hello").dropFirst(0), PublishersOptional("Hello"))
        XCTAssertEqual(TestOptional(.error).dropFirst(), PublishersOptional(.error))
        XCTAssertEqual(TestOptional(.error).dropFirst(0), PublishersOptional(.error))

        XCTAssertEqual(TestOptional(nil).drop { $0 == "Hello" }, PublishersOptional(nil))
        XCTAssertEqual(TestOptional("Hello").drop { $0 == "Hello" }, PublishersOptional(nil))
        XCTAssertEqual(TestOptional("Hello").drop { $0 != "Hello" }, PublishersOptional("Hello"))
        XCTAssertEqual(TestOptional(.error).drop { $0 == "Hello" }, PublishersOptional(.error))
        XCTAssertEqual(TestOptional(.error).drop { $0 != "Hello" }, PublishersOptional(.error))

        XCTAssertEqual(
            TestOptional(nil)
                .tryDrop { $0 == "Hello" }
                .mapError { $0 as! TestError },
            PublishersOptional(nil)
        )
        XCTAssertEqual(
            TestOptional(nil)
                .tryDrop { _ in throw TestError.error }
                .mapError { $0 as! TestError },
            PublishersOptional(nil)
        )
        XCTAssertEqual(
            TestOptional("Hello")
                .tryDrop { $0 == "Hello" }
                .mapError { $0 as! TestError },
            PublishersOptional(nil)
        )
        XCTAssertEqual(
            TestOptional("Hello")
                .tryDrop { $0 != "Hello" }
                .mapError { $0 as! TestError },
            PublishersOptional("Hello")
        )
        XCTAssertEqual(
            TestOptional("Hello")
                .tryDrop { _ in throw TestError.error }
                .mapError { $0 as! TestError },
            PublishersOptional(.error)
        )
        XCTAssertEqual(
            TestOptional(.error)
                .tryDrop { $0 == "Hello" }
                .mapError { $0 as! TestError },
            PublishersOptional(.error)
        )
        XCTAssertEqual(
            TestOptional(.error)
                .tryDrop { $0 != "Hello" }
                .mapError { $0 as! TestError },
            PublishersOptional(.error)
        )
        XCTAssertEqual(
            TestOptional(.error)
                .tryDrop { _ in throw TestError.otherError }
                .mapError { $0 as! TestError },
            PublishersOptional(.error)
        )
    }

    func testFirst() {
        XCTAssertEqual(TestOptional(nil).first(), PublishersOptional(nil))
        XCTAssertEqual(TestOptional("Hello").first(), PublishersOptional("Hello"))
        XCTAssertEqual(TestOptional(.error).first(), PublishersOptional(.error))

        XCTAssertEqual(TestOptional(nil).first { $0 == "Hello" }, PublishersOptional(nil))
        XCTAssertEqual(TestOptional("Hello").first { $0 == "Hello" }, PublishersOptional("Hello"))
        XCTAssertEqual(TestOptional("Hello").first { $0 != "Hello" }, PublishersOptional(nil))
        XCTAssertEqual(TestOptional(.error).first { $0 == "Hello" }, PublishersOptional(.error))
        XCTAssertEqual(TestOptional(.error).first { $0 != "Hello" }, PublishersOptional(.error))

        XCTAssertEqual(
            TestOptional(nil)
                .tryFirst { $0 == "Hello" }
                .mapError { $0 as! TestError },
            PublishersOptional(nil)
        )
        XCTAssertEqual(
            TestOptional(nil)
                .tryFirst { _ in throw TestError.error }
                .mapError { $0 as! TestError },
            PublishersOptional(nil)
        )
        XCTAssertEqual(
            TestOptional("Hello")
                .tryFirst { $0 == "Hello" }
                .mapError { $0 as! TestError },
            PublishersOptional("Hello")
        )
        XCTAssertEqual(
            TestOptional("Hello")
                .tryFirst { $0 != "Hello" }
                .mapError { $0 as! TestError },
            PublishersOptional(nil)
        )
        XCTAssertEqual(
            TestOptional("Hello")
                .tryFirst { _ in throw TestError.error }
                .mapError { $0 as! TestError },
            PublishersOptional(.error)
        )
        XCTAssertEqual(
            TestOptional(.error)
                .tryFirst { $0 == "Hello" }
                .mapError { $0 as! TestError },
            PublishersOptional(.error)
        )
        XCTAssertEqual(
            TestOptional(.error)
                .tryFirst { $0 != "Hello" }
                .mapError { $0 as! TestError },
            PublishersOptional(.error)
        )
        XCTAssertEqual(
            TestOptional(.error)
                .tryFirst { _ in throw TestError.otherError }
                .mapError { $0 as! TestError },
            PublishersOptional(.error)
        )
    }

    func testLast() {
        XCTAssertEqual(TestOptional(nil).last(), PublishersOptional(nil))
        XCTAssertEqual(TestOptional("Hello").last(), PublishersOptional("Hello"))
        XCTAssertEqual(TestOptional(.error).last(), PublishersOptional(.error))

        XCTAssertEqual(TestOptional(nil).last { $0 == "Hello" }, PublishersOptional(nil))
        XCTAssertEqual(TestOptional("Hello").last { $0 == "Hello" }, PublishersOptional("Hello"))
        XCTAssertEqual(TestOptional("Hello").last { $0 != "Hello" }, PublishersOptional(nil))
        XCTAssertEqual(TestOptional(.error).last { $0 == "Hello" }, PublishersOptional(.error))
        XCTAssertEqual(TestOptional(.error).last { $0 != "Hello" }, PublishersOptional(.error))

        XCTAssertEqual(
            TestOptional(nil)
                .tryLast { $0 == "Hello" }
                .mapError { $0 as! TestError },
            PublishersOptional(nil)
        )
        XCTAssertEqual(
            TestOptional(nil)
                .tryLast { _ in throw TestError.error }
                .mapError { $0 as! TestError },
            PublishersOptional(nil)
        )
        XCTAssertEqual(
            TestOptional("Hello")
                .tryLast { $0 == "Hello" }
                .mapError { $0 as! TestError },
            PublishersOptional("Hello")
        )
        XCTAssertEqual(
            TestOptional("Hello")
                .tryLast { $0 != "Hello" }
                .mapError { $0 as! TestError },
            PublishersOptional(nil)
        )
        XCTAssertEqual(
            TestOptional("Hello")
                .tryLast { _ in throw TestError.error }
                .mapError { $0 as! TestError },
            PublishersOptional(.error)
        )
        XCTAssertEqual(
            TestOptional(.error)
                .tryLast { $0 == "Hello" }
                .mapError { $0 as! TestError },
            PublishersOptional(.error)
        )
        XCTAssertEqual(
            TestOptional(.error)
                .tryLast { $0 != "Hello" }
                .mapError { $0 as! TestError },
            PublishersOptional(.error)
        )
        XCTAssertEqual(
            TestOptional(.error)
                .tryLast { _ in throw TestError.otherError }
                .mapError { $0 as! TestError },
            PublishersOptional(.error)
        )
    }

    func testFilter() {
        XCTAssertEqual(TestOptional(nil).filter { $0 == "Hello" }, PublishersOptional(nil))
        XCTAssertEqual(TestOptional("Hello").filter { $0 == "Hello" }, PublishersOptional("Hello"))
        XCTAssertEqual(TestOptional("Hello").filter { $0 != "Hello" }, PublishersOptional(nil))
        XCTAssertEqual(TestOptional(.error).filter { $0 == "Hello" }, PublishersOptional(.error))
        XCTAssertEqual(TestOptional(.error).filter { $0 != "Hello" }, PublishersOptional(.error))

        XCTAssertEqual(
            TestOptional(nil)
                .tryFilter { $0 == "Hello" }
                .mapError { $0 as! TestError },
            PublishersOptional(nil)
        )
        XCTAssertEqual(
            TestOptional(nil)
                .tryFilter { _ in throw TestError.error }
                .mapError { $0 as! TestError },
            PublishersOptional(nil)
        )
        XCTAssertEqual(
            TestOptional("Hello")
                .tryFilter { $0 == "Hello" }
                .mapError { $0 as! TestError },
            PublishersOptional("Hello")
        )
        XCTAssertEqual(
            TestOptional("Hello")
                .tryFilter { $0 != "Hello" }
                .mapError { $0 as! TestError },
            PublishersOptional(nil)
        )
        XCTAssertEqual(
            TestOptional("Hello")
                .tryFilter { _ in throw TestError.error }
                .mapError { $0 as! TestError },
            PublishersOptional(.error)
        )
        XCTAssertEqual(
            TestOptional(.error)
                .tryFilter { $0 == "Hello" }
                .mapError { $0 as! TestError },
            PublishersOptional(.error)
        )
        XCTAssertEqual(
            TestOptional(.error)
                .tryLast { $0 != "Hello" }
                .mapError { $0 as! TestError },
            PublishersOptional(.error)
        )
        XCTAssertEqual(
            TestOptional(.error)
                .tryLast { _ in throw TestError.otherError }
                .mapError { $0 as! TestError },
            PublishersOptional(.error)
        )
    }

    func testIgnoreOutput() {
        XCTAssertEqual(TestOptional(nil).ignoreOutput(), Publishers.Empty())
        XCTAssertEqual(TestOptional("Hello").ignoreOutput(), Publishers.Empty())
        XCTAssertEqual(TestOptional(.error).ignoreOutput(), Publishers.Empty())
    }

    func testMap() {
        XCTAssertEqual(TestOptional(nil).map { "!\($0)!" }, PublishersOptional(nil))
        XCTAssertEqual(TestOptional("Hello").map { "!\($0)!" }, PublishersOptional("!Hello!"))
        XCTAssertEqual(TestOptional(.error).map { "!\($0)!" }, PublishersOptional(.error))

        XCTAssertEqual(
            TestOptional(nil)
                .tryMap { "!\($0)!" }
                .mapError { $0 as! TestError },
            PublishersOptional(nil)
        )
        XCTAssertEqual(
            TestOptional(nil)
                .tryMap { (_) -> String in throw TestError.error }
                .mapError { $0 as! TestError },
            PublishersOptional(nil)
        )
        XCTAssertEqual(
            TestOptional("Hello")
                .tryMap { "!\($0)!" }
                .mapError { $0 as! TestError },
            PublishersOptional("!Hello!")
        )
        XCTAssertEqual(
            TestOptional("Hello")
                .tryMap { (_) -> String in throw TestError.error }
                .mapError { $0 as! TestError },
            PublishersOptional(.error)
        )
        XCTAssertEqual(
            TestOptional(.error)
                .tryMap { "!\($0)!" }
                .mapError { $0 as! TestError },
            PublishersOptional(.error)
        )
        XCTAssertEqual(
            TestOptional(.error)
                .tryMap { (_) -> String in throw TestError.otherError }
                .mapError { $0 as! TestError },
            PublishersOptional(.error)
        )
    }

    func testMapError() {
        XCTAssertEqual(TestOptional(nil).mapError { _ in TestError.error }, PublishersOptional(nil))
        XCTAssertEqual(TestOptional("Hello").mapError { _ in TestError.error }, PublishersOptional("Hello"))
        XCTAssertEqual(TestOptional(.error).mapError { _ in TestError.otherError }, PublishersOptional(.otherError))
    }

    func testOutput() {
        XCTAssertEqual(TestOptional(nil).output(at: 0), PublishersOptional(nil))
        XCTAssertEqual(TestOptional("Hello").output(at: 0), PublishersOptional("Hello"))
        XCTAssertEqual(TestOptional("Hello").output(at: 1), PublishersOptional(nil))
        XCTAssertEqual(TestOptional(.error).output(at: 0), PublishersOptional(.error))
        XCTAssertEqual(TestOptional(.error).output(at: 1), PublishersOptional(.error))

        XCTAssertEqual(TestOptional(nil).output(in: ...1), PublishersOptional(nil))
        XCTAssertEqual(TestOptional("Hello").output(in: ...1), PublishersOptional("Hello"))
        XCTAssertEqual(TestOptional("Hello").output(in: 1...), PublishersOptional(nil))
        XCTAssertEqual(TestOptional(.error).output(in: ...1), PublishersOptional(.error))
        XCTAssertEqual(TestOptional(.error).output(in: 1...), PublishersOptional(.error))
    }

    func testPrefix() {
        XCTAssertEqual(TestOptional(nil).prefix(0), PublishersOptional(nil))
        XCTAssertEqual(TestOptional("Hello").prefix(0), PublishersOptional(nil))
        XCTAssertEqual(TestOptional("Hello").prefix(1), PublishersOptional("Hello"))
        XCTAssertEqual(TestOptional(.error).prefix(0), PublishersOptional(.error))
        XCTAssertEqual(TestOptional(.error).prefix(1), PublishersOptional(.error))

        XCTAssertEqual(TestOptional(nil).prefix(while: { $0 == "Hello" }), PublishersOptional(nil))
        XCTAssertEqual(TestOptional("Hello").prefix(while: { $0 == "Hello" }), PublishersOptional("Hello"))
        XCTAssertEqual(TestOptional("Hello").prefix(while: { $0 != "Hello" }), PublishersOptional(nil))
        XCTAssertEqual(TestOptional(.error).prefix(while: { $0 == "Hello" }), PublishersOptional(.error))
        XCTAssertEqual(TestOptional(.error).prefix(while: { $0 != "Hello" }), PublishersOptional(.error))

        XCTAssertEqual(
            TestOptional(nil)
                .tryPrefix(while: { $0 == "Hello" })
                .mapError { $0 as! TestError },
            PublishersOptional(nil)
        )
        XCTAssertEqual(
            TestOptional(nil)
                .tryPrefix(while: { _ in throw TestError.error })
                .mapError { $0 as! TestError },
            PublishersOptional(nil)
        )
        XCTAssertEqual(
            TestOptional("Hello")
                .tryPrefix(while: { $0 == "Hello" })
                .mapError { $0 as! TestError },
            PublishersOptional("Hello")
        )
        XCTAssertEqual(
            TestOptional("Hello")
                .tryPrefix(while: { $0 != "Hello" })
                .mapError { $0 as! TestError },
            PublishersOptional(nil)
        )
        XCTAssertEqual(
            TestOptional("Hello")
                .tryPrefix(while: { _ in throw TestError.error })
                .mapError { $0 as! TestError },
            PublishersOptional(.error)
        )
        XCTAssertEqual(
            TestOptional(.error)
                .tryPrefix(while: { $0 == "Hello" })
                .mapError { $0 as! TestError },
            PublishersOptional(.error)
        )
        XCTAssertEqual(
            TestOptional(.error)
                .tryPrefix(while: { $0 != "Hello" })
                .mapError { $0 as! TestError },
            PublishersOptional(.error)
        )
        XCTAssertEqual(
            TestOptional(.error)
                .tryPrefix(while: { _ in throw TestError.otherError })
                .mapError { $0 as! TestError },
            PublishersOptional(.error)
        )
    }

    func testReduce() {
        XCTAssertEqual(TestOptional(nil).reduce(0) { $0 + $1.count }, PublishersOptional(nil))
        XCTAssertEqual(TestOptional("Hello").reduce(0) { $0 + $1.count }, PublishersOptional("Hello".count))
        XCTAssertEqual(TestOptional(.error).reduce(0) { $0 + $1.count }, PublishersOptional(.error))

        XCTAssertEqual(
            TestOptional(nil)
                .tryReduce(0) { $0 + $1.count }
                .mapError { $0 as! TestError },
            PublishersOptional(nil)
        )
        XCTAssertEqual(
            TestOptional(nil)
                .tryReduce(0) { _, _ in throw TestError.error }
                .mapError { $0 as! TestError },
            PublishersOptional(nil)
        )
        XCTAssertEqual(
            TestOptional("Hello")
                .tryReduce(0) { $0 + $1.count }
                .mapError { $0 as! TestError },
            PublishersOptional("Hello".count)
        )
        XCTAssertEqual(
            TestOptional("Hello")
                .tryReduce(0) { _, _ in throw TestError.error }
                .mapError { $0 as! TestError },
            PublishersOptional(.error)
        )
        XCTAssertEqual(
            TestOptional(.error)
                .tryReduce(0) { $0 + $1.count }
                .mapError { $0 as! TestError },
            PublishersOptional(.error)
        )
        XCTAssertEqual(
            TestOptional(.error)
                .tryReduce(0) { _, _ in throw TestError.otherError }
                .mapError { $0 as! TestError },
            PublishersOptional(.error)
        )
    }

    func testRemoveDuplicates() {
        XCTAssertEqual(TestOptional(nil).removeDuplicates(), PublishersOptional(nil))
        XCTAssertEqual(TestOptional(nil).removeDuplicates(by: { _, _ in false }), PublishersOptional(nil))
        XCTAssertEqual(TestOptional("Hello").removeDuplicates(), PublishersOptional("Hello"))
        XCTAssertEqual(TestOptional("Hello").removeDuplicates(by: { _, _ in false }), PublishersOptional("Hello"))
        XCTAssertEqual(TestOptional(.error).removeDuplicates(), PublishersOptional(.error))
        XCTAssertEqual(TestOptional(.error).removeDuplicates(by: { _, _ in false }), PublishersOptional(.error))

        XCTAssertEqual(
            TestOptional(nil)
                .tryRemoveDuplicates(by: { _, _ in false })
                .mapError { $0 as! TestError },
            PublishersOptional(nil)
        )
        XCTAssertEqual(
            TestOptional(nil)
                .tryRemoveDuplicates(by: { _, _ in throw TestError.error })
                .mapError { $0 as! TestError },
            PublishersOptional(nil)
        )
        XCTAssertEqual(
            TestOptional("Hello")
                .tryRemoveDuplicates(by: { _, _ in false })
                .mapError { $0 as! TestError },
            PublishersOptional("Hello")
        )
        XCTAssertEqual(
            TestOptional("Hello")
                .tryRemoveDuplicates(by: { _, _ in throw TestError.error })
                .mapError { $0 as! TestError },
            PublishersOptional("Hello")
        )
        XCTAssertEqual(
            TestOptional(.error)
                .tryRemoveDuplicates(by: { _, _ in false })
                .mapError { $0 as! TestError },
            PublishersOptional(.error)
        )
        XCTAssertEqual(
            TestOptional(.error)
                .tryRemoveDuplicates(by: { _, _ in throw TestError.otherError })
                .mapError { $0 as! TestError },
            PublishersOptional(.error)
        )
    }

    func testReplaceError() {
        XCTAssertEqual(TestOptional(nil).replaceError(with: "World"), PublishersOptional(nil))
        XCTAssertEqual(TestOptional("Hello").replaceError(with: "World"), PublishersOptional("Hello"))
        XCTAssertEqual(TestOptional(.error).replaceError(with: "World"), PublishersOptional("World"))
    }

    func testReplaceEmpty() {
        XCTAssertEqual(TestOptional(nil).replaceEmpty(with: "World"), PublishersOptional("World"))
        XCTAssertEqual(TestOptional("Hello").replaceEmpty(with: "World"), PublishersOptional("Hello"))
        XCTAssertEqual(TestOptional(.error).replaceEmpty(with: "World"), PublishersOptional(.error))
    }

    func testRetry() {
        XCTAssertEqual(TestOptional(nil).retry(42), PublishersOptional(nil))
        XCTAssertEqual(TestOptional(nil).retry(), PublishersOptional(nil))
        XCTAssertEqual(TestOptional("Hello").retry(42), PublishersOptional("Hello"))
        XCTAssertEqual(TestOptional("Hello").retry(), PublishersOptional("Hello"))
        XCTAssertEqual(TestOptional(.error).retry(42), PublishersOptional(.error))
        XCTAssertEqual(TestOptional(.error).retry(), PublishersOptional(.error))
    }

    func testScan() {
        XCTAssertEqual(TestOptional(nil).scan(0) { $0 + $1.count }, PublishersOptional(nil))
        XCTAssertEqual(TestOptional("Hello").scan(0) { $0 + $1.count }, PublishersOptional("Hello".count))
        XCTAssertEqual(TestOptional(.error).scan(0) { $0 + $1.count }, PublishersOptional(.error))

        XCTAssertEqual(
            TestOptional(nil)
                .tryScan(0) { $0 + $1.count }
                .mapError { $0 as! TestError },
            PublishersOptional(nil)
        )
        XCTAssertEqual(
            TestOptional(nil)
                .tryScan(0) { _, _ in throw TestError.error }
                .mapError { $0 as! TestError },
            PublishersOptional(nil)
        )
        XCTAssertEqual(
            TestOptional("Hello")
                .tryScan(0) { $0 + $1.count }
                .mapError { $0 as! TestError },
            PublishersOptional("Hello".count)
        )
        XCTAssertEqual(
            TestOptional("Hello")
                .tryScan(0) { _, _ in throw TestError.error }
                .mapError { $0 as! TestError },
            PublishersOptional(.error)
        )
        XCTAssertEqual(
            TestOptional(.error)
                .tryScan(0) { $0 + $1.count }
                .mapError { $0 as! TestError },
            PublishersOptional(.error)
        )
        XCTAssertEqual(
            TestOptional(.error)
                .tryScan(0) { _, _ in throw TestError.otherError }
                .mapError { $0 as! TestError },
            PublishersOptional(.error)
        )
    }
}
