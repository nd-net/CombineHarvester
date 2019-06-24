//
//  CompactMapTests.swift
//  CombineHarvesterTests
//
//  Created by Andreas Hartl on 24.06.19.
//

import XCTest

class CompactMapTests: XCTestCase {
    let hello: [Result<String, TestError>] = [.success("Hello"), .success("World")]
    let error: [Result<String, TestError>] = [.success("Hello"), .failure(.error)]

    func testCompactMap() {
        var publisher = TestPublisher(hello)
            .compactMap { $0 == "Hello" ? nil : $0 }
        var receiver = TestSubject<String, TestError>()

        var subscription = publisher.subscribe(receiver)

        XCTAssertEqual(receiver.values, ["World"])
        XCTAssertEqual(receiver.completion, [.finished])

        publisher = TestPublisher(self.hello)
            .compactMap { $0 == "Hello" ? nil : $0 }
            .compactMap { $0 == "World" ? nil : $0 }
        receiver = TestSubject<String, TestError>()

        subscription = publisher.subscribe(receiver)

        XCTAssertEqual(receiver.values, [])
        XCTAssertEqual(receiver.completion, [.finished])

        publisher = TestPublisher(self.error)
            .compactMap { $0 == "Hello" ? nil : $0 }
        receiver = TestSubject<String, TestError>()

        subscription = publisher.subscribe(receiver)

        XCTAssertEqual(receiver.values, [])
        XCTAssertEqual(receiver.completion, [.failure(.error)])

        _ = subscription
    }

    func testTryCompactMap() {
        var publisher = TestPublisher(hello)
            .tryCompactMap { $0 == "Hello" ? nil : $0 }
            .mapError { $0 as! TestError }
        var receiver = TestSubject<String, TestError>()

        var subscription = publisher.subscribe(receiver)

        XCTAssertEqual(receiver.values, ["World"])
        XCTAssertEqual(receiver.completion, [.finished])

        publisher = TestPublisher(self.hello)
            .tryCompactMap { $0 == "Hello" ? nil : $0 }
            .mapError { $0 as! TestError }
        receiver = TestSubject<String, TestError>()

        subscription = publisher.subscribe(receiver)

        XCTAssertEqual(receiver.values, ["World"])
        XCTAssertEqual(receiver.completion, [.finished])

        publisher = TestPublisher(self.hello + [.success("Foo")])
            .tryCompactMap { if $0 == "Hello" {
                return nil
            }
            throw TestError.error
            }
            .mapError { $0 as! TestError }
        receiver = TestSubject<String, TestError>()

        subscription = publisher.subscribe(receiver)

        XCTAssertEqual(receiver.values, [])
        XCTAssertEqual(receiver.completion, [.failure(.error)])

        _ = subscription
    }
}
