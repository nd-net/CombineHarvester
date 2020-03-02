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
