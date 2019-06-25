//
//  FilterTests.swift
//  CombineHarvesterTests
//
//  Created by Andreas Hartl on 25.06.19.
//

import XCTest
@testable import CombineHarvester

class FilterTests: XCTestCase {
    func testFilter() {
        var publisher: TestPublisher<String, TestError>
        var receiver: TestSubject<String, TestError>
        var subscription: AnyCancellable

        publisher = TestPublisher.success([])
        receiver = TestSubject()
        subscription = publisher
            .filter { $0 == "Hello" }
            .subscribe(receiver)

        XCTAssertEqual(receiver.values, [])
        XCTAssertEqual(receiver.completion, [.finished])

        publisher = TestPublisher.success(["Hello"])
        receiver = TestSubject()
        subscription = publisher
            .filter { $0 == "Hello" }
            .subscribe(receiver)

        XCTAssertEqual(receiver.values, ["Hello"])
        XCTAssertEqual(receiver.completion, [.finished])

        publisher = TestPublisher.success(["Hello"])
        receiver = TestSubject()
        subscription = publisher
            .filter { $0 != "Hello" }
            .subscribe(receiver)

        XCTAssertEqual(receiver.values, [])
        XCTAssertEqual(receiver.completion, [.finished])

        publisher = TestPublisher.success(["Hello", "World"])
        receiver = TestSubject()
        subscription = publisher
            .filter { $0 != "Hello" }
            .subscribe(receiver)

        XCTAssertEqual(receiver.values, ["World"])
        XCTAssertEqual(receiver.completion, [.finished])

        publisher = TestPublisher(.success("Hello"), .success("World"), .failure(.error))
        receiver = TestSubject()
        subscription = publisher
            .filter { $0 != "Hello" }
            .subscribe(receiver)

        XCTAssertEqual(receiver.values, ["World"])
        XCTAssertEqual(receiver.completion, [.failure(.error)])

        publisher = TestPublisher.success([])
        receiver = TestSubject()
        subscription = publisher
            .tryFilter { $0 == "Hello" }
            .mapError { $0 as! TestError }
            .subscribe(receiver)

        XCTAssertEqual(receiver.values, [])
        XCTAssertEqual(receiver.completion, [.finished])

        publisher = TestPublisher.success(["Hello"])
        receiver = TestSubject()
        subscription = publisher
            .tryFilter { $0 == "Hello" }
            .mapError { $0 as! TestError }
            .subscribe(receiver)

        XCTAssertEqual(receiver.values, ["Hello"])
        XCTAssertEqual(receiver.completion, [.finished])

        publisher = TestPublisher.success(["Hello"])
        receiver = TestSubject()
        subscription = publisher
            .tryFilter { $0 != "Hello" }
            .mapError { $0 as! TestError }
            .subscribe(receiver)

        XCTAssertEqual(receiver.values, [])
        XCTAssertEqual(receiver.completion, [.finished])

        publisher = TestPublisher.success(["Hello", "World"])
        receiver = TestSubject()
        subscription = publisher
            .tryFilter { $0 != "Hello" }
            .mapError { $0 as! TestError }
            .subscribe(receiver)

        XCTAssertEqual(receiver.values, ["World"])
        XCTAssertEqual(receiver.completion, [.finished])

        publisher = TestPublisher(.success("Hello"), .success("World"), .failure(.error))
        receiver = TestSubject()
        subscription = publisher
            .tryFilter { $0 != "Hello" }
            .mapError { $0 as! TestError }
            .subscribe(receiver)

        XCTAssertEqual(receiver.values, ["World"])
        XCTAssertEqual(receiver.completion, [.failure(.error)])

        publisher = TestPublisher.success([])
        receiver = TestSubject()
        subscription = publisher
            .tryFilter { if $0 == "World" {
                throw TestError.error
            }
            return true
            }
            .mapError { $0 as! TestError }
            .subscribe(receiver)

        XCTAssertEqual(receiver.values, [])
        XCTAssertEqual(receiver.completion, [.finished])

        publisher = TestPublisher.success(["Hello", "World"])
        receiver = TestSubject()
        subscription = publisher
            .tryFilter { if $0 == "World" {
                throw TestError.error
            }
            return true
            }
            .mapError { $0 as! TestError }
            .subscribe(receiver)

        XCTAssertEqual(receiver.values, ["Hello"])
        XCTAssertEqual(receiver.completion, [.failure(.error)])

        publisher = TestPublisher(.success("Hello"), .success("World"), .failure(.error))
        receiver = TestSubject()
        subscription = publisher
            .tryFilter { if $0 == "World" {
                throw TestError.otherError
            }
            return true
            }
            .mapError { $0 as! TestError }
            .subscribe(receiver)

        XCTAssertEqual(receiver.values, ["Hello"])
        XCTAssertEqual(receiver.completion, [.failure(.otherError)])
        _ = subscription
    }

    func testCompositeFilter() {
        let lorem = ["Lorem", "ipsum", "dolor", "sit", "amet"]

        var publisher: TestPublisher<String, TestError>
        var receiver: TestSubject<String, TestError>
        var subscription: AnyCancellable

        publisher = TestPublisher.success(lorem)
        receiver = TestSubject()
        subscription = publisher
            .filter { $0 != "Lorem" }
            .filter { $0 != "ipsum" }
            .subscribe(receiver)

        XCTAssertEqual(receiver.values, ["dolor", "sit", "amet"])
        XCTAssertEqual(receiver.completion, [.finished])

        publisher = TestPublisher.success(lorem)
        receiver = TestSubject()
        subscription = publisher
            .tryFilter { $0 != "Lorem" }
            .filter { $0 != "ipsum" }
            .mapError { $0 as! TestError }
            .subscribe(receiver)

        XCTAssertEqual(receiver.values, ["dolor", "sit", "amet"])
        XCTAssertEqual(receiver.completion, [.finished])

        publisher = TestPublisher.success(lorem)
        receiver = TestSubject()
        subscription = publisher
            .filter { $0 != "Lorem" }
            .tryFilter { $0 != "ipsum" }
            .mapError { $0 as! TestError }
            .subscribe(receiver)

        XCTAssertEqual(receiver.values, ["dolor", "sit", "amet"])
        XCTAssertEqual(receiver.completion, [.finished])

        publisher = TestPublisher.success(lorem)
        receiver = TestSubject()
        subscription = publisher
            .tryFilter { $0 != "Lorem" }
            .tryFilter { $0 != "ipsum" }
            .mapError { $0 as! TestError }
            .subscribe(receiver)

        XCTAssertEqual(receiver.values, ["dolor", "sit", "amet"])
        XCTAssertEqual(receiver.completion, [.finished])

        publisher = TestPublisher.success(lorem)
        receiver = TestSubject()
        subscription = publisher
            .tryFilter { _ in throw TestError.error }
            .filter { $0 != "ipsum" }
            .mapError { $0 as! TestError }
            .subscribe(receiver)

        XCTAssertEqual(receiver.values, [])
        XCTAssertEqual(receiver.completion, [.failure(.error)])

        publisher = TestPublisher.success(lorem)
        receiver = TestSubject()
        subscription = publisher
            .filter { $0 != "Lorem" }
            .tryFilter { _ in throw TestError.error }
            .mapError { $0 as! TestError }
            .subscribe(receiver)

        XCTAssertEqual(receiver.values, [])
        XCTAssertEqual(receiver.completion, [.failure(.error)])

        publisher = TestPublisher.success(lorem)
        receiver = TestSubject()
        subscription = publisher
            .tryFilter { _ in throw TestError.error }
            .tryFilter { _ in throw TestError.otherError }
            .mapError { $0 as! TestError }
            .subscribe(receiver)

        XCTAssertEqual(receiver.values, [])
        XCTAssertEqual(receiver.completion, [.failure(.error)])

        _ = subscription
    }
}
