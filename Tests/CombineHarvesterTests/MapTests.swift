//
//  MapTests.swift
//  CombineHarvesterTests
//
//  Created by Andreas Hartl on 24.06.19.
//

import XCTest

class MapTests: XCTestCase {
    let hello: [Result<String, TestError>] = [.success("Hello"), .success("World")]
    let nothing: [Result<String?, TestError>] = [.success(nil)]
    let error: [Result<String, TestError>] = [.success("Hello"), .failure(.error)]

    func testMap() {
        var publisher = TestPublisher(hello).map { "!\($0)!" }
        var receiver = TestSubject<String, TestError>()

        var subscription = publisher.subscribe(receiver)

        XCTAssertEqual(receiver.values, ["!Hello!", "!World!"])
        XCTAssertEqual(receiver.completion, [.finished])

        publisher = TestPublisher(self.hello)
            .map { $0 + "!" }.map { "!" + $0 }
        receiver = TestSubject<String, TestError>()

        subscription = publisher.subscribe(receiver)

        XCTAssertEqual(receiver.values, ["!Hello!", "!World!"])
        XCTAssertEqual(receiver.completion, [.finished])

        publisher = TestPublisher(self.error).map { "!\($0)!" }
        receiver = TestSubject<String, TestError>()

        subscription = publisher.subscribe(receiver)

        XCTAssertEqual(receiver.values, ["!Hello!"])
        XCTAssertEqual(receiver.completion, [.failure(.error)])

        _ = subscription
    }

    func testTryMap() {
        var publisher = TestPublisher(hello)
            .tryMap { "!\($0)!" }
            .mapError { $0 as! TestError }
        var receiver = TestSubject<String, TestError>()

        var subscription = publisher.subscribe(receiver)

        XCTAssertEqual(receiver.values, ["!Hello!", "!World!"])
        XCTAssertEqual(receiver.completion, [.finished])

        publisher = TestPublisher(self.hello)
            .map { $0 + "!" }.tryMap { "!" + $0 }
            .mapError { $0 as! TestError }

        receiver = TestSubject<String, TestError>()

        subscription = publisher.subscribe(receiver)

        XCTAssertEqual(receiver.values, ["!Hello!", "!World!"])
        XCTAssertEqual(receiver.completion, [.finished])

        publisher = TestPublisher(self.hello)
            .tryMap { $0 + "!" }.map { "!" + $0 }
            .mapError { $0 as! TestError }

        receiver = TestSubject<String, TestError>()

        subscription = publisher.subscribe(receiver)

        XCTAssertEqual(receiver.values, ["!Hello!", "!World!"])
        XCTAssertEqual(receiver.completion, [.finished])

        publisher = TestPublisher(self.hello)
            .tryMap { $0 + "!" }.tryMap { "!" + $0 }
            .mapError { $0 as! TestError }

        receiver = TestSubject<String, TestError>()

        subscription = publisher.subscribe(receiver)

        XCTAssertEqual(receiver.values, ["!Hello!", "!World!"])
        XCTAssertEqual(receiver.completion, [.finished])

        publisher = TestPublisher(self.error)
            .tryMap { "!\($0)!" }
            .mapError { $0 as! TestError }
        receiver = TestSubject<String, TestError>()

        subscription = publisher.subscribe(receiver)

        XCTAssertEqual(receiver.values, ["!Hello!"])
        XCTAssertEqual(receiver.completion, [.failure(.error)])

        publisher = TestPublisher(self.hello)
            .map { "!" + $0 }.tryMap { val in
                if val.contains("World") {
                    throw TestError.otherError
                }
                return val
            }
            .mapError { $0 as! TestError }
        receiver = TestSubject<String, TestError>()

        subscription = publisher.subscribe(receiver)

        XCTAssertEqual(receiver.values, ["!Hello"])
        XCTAssertEqual(receiver.completion, [.failure(.otherError)])

        publisher = TestPublisher(self.error)
            .tryMap { _ in throw TestError.otherError }
            .mapError { $0 as! TestError }
        receiver = TestSubject<String, TestError>()

        subscription = publisher.subscribe(receiver)

        XCTAssertEqual(receiver.values, [])
        XCTAssertEqual(receiver.completion, [.failure(.otherError)])

        _ = subscription
    }

    func testReplaceNil() {
        let publisher = TestPublisher(nothing)
            .replaceNil(with: "World")
        let receiver = TestSubject<String, TestError>()

        let subscription = publisher.subscribe(receiver)

        XCTAssertEqual(receiver.values, ["World"])
        XCTAssertEqual(receiver.completion, [.finished])

        _ = subscription
    }
}
