//
//  ComparisonTests.swift
//  CombineHarvesterTests
//
//  Created by Andreas Hartl on 25.06.19.
//

import XCTest
@testable import CombineHarvester

class ComparisonTests: XCTestCase {
    func testMin() {
        var publisher: TestPublisher<String, TestError>
        var receiver: TestSubject<String, TestError>
        var subscription: AnyCancellable

        publisher = TestPublisher.success([])
        receiver = TestSubject()
        subscription = publisher
            .min()
            .subscribe(receiver)

        XCTAssertEqual(receiver.values, [])
        XCTAssertEqual(receiver.completion, [.finished])

        publisher = TestPublisher.success(["Hello"])
        receiver = TestSubject()
        subscription = publisher
            .min()
            .subscribe(receiver)

        XCTAssertEqual(receiver.values, ["Hello"])
        XCTAssertEqual(receiver.completion, [.finished])

        publisher = TestPublisher.success(["Hello", "World"])
        receiver = TestSubject()
        subscription = publisher
            .min()
            .subscribe(receiver)

        XCTAssertEqual(receiver.values, ["Hello"])
        XCTAssertEqual(receiver.completion, [.finished])

        publisher = TestPublisher(.success("Hello"), .success("World"), .failure(.error))
        receiver = TestSubject()
        subscription = publisher
            .min()
            .subscribe(receiver)

        XCTAssertEqual(receiver.values, [])
        XCTAssertEqual(receiver.completion, [.failure(.error)])

        publisher = TestPublisher.success([])
        receiver = TestSubject()
        subscription = publisher
            .min(by: >)
            .subscribe(receiver)

        XCTAssertEqual(receiver.values, [])
        XCTAssertEqual(receiver.completion, [.finished])

        publisher = TestPublisher.success(["Hello"])
        receiver = TestSubject()
        subscription = publisher
            .min(by: >)
            .subscribe(receiver)

        XCTAssertEqual(receiver.values, ["Hello"])
        XCTAssertEqual(receiver.completion, [.finished])

        publisher = TestPublisher.success(["Hello", "World"])
        receiver = TestSubject()
        subscription = publisher
            .min(by: >)
            .subscribe(receiver)

        XCTAssertEqual(receiver.values, ["World"])
        XCTAssertEqual(receiver.completion, [.finished])

        publisher = TestPublisher(.success("Hello"), .success("World"), .failure(.error))
        receiver = TestSubject()
        subscription = publisher
            .min(by: >)
            .subscribe(receiver)

        XCTAssertEqual(receiver.values, [])
        XCTAssertEqual(receiver.completion, [.failure(.error)])

        publisher = TestPublisher.success([])
        receiver = TestSubject()
        subscription = publisher
            .tryMin(by: >)
            .mapError { $0 as! TestError }
            .subscribe(receiver)

        XCTAssertEqual(receiver.values, [])
        XCTAssertEqual(receiver.completion, [.finished])

        publisher = TestPublisher.success(["Hello"])
        receiver = TestSubject()
        subscription = publisher
            .tryMin(by: >)
            .mapError { $0 as! TestError }
            .subscribe(receiver)

        XCTAssertEqual(receiver.values, ["Hello"])
        XCTAssertEqual(receiver.completion, [.finished])

        publisher = TestPublisher.success(["Hello", "World"])
        receiver = TestSubject()
        subscription = publisher
            .tryMin(by: >)
            .mapError { $0 as! TestError }
            .subscribe(receiver)

        XCTAssertEqual(receiver.values, ["World"])
        XCTAssertEqual(receiver.completion, [.finished])

        publisher = TestPublisher(.success("Hello"), .success("World"), .failure(.error))
        receiver = TestSubject()
        subscription = publisher
            .tryMin(by: >)
            .mapError { $0 as! TestError }
            .subscribe(receiver)

        XCTAssertEqual(receiver.values, [])
        XCTAssertEqual(receiver.completion, [.failure(.error)])

        publisher = TestPublisher.success([])
        receiver = TestSubject()
        subscription = publisher
            .tryMin(by: { _, _ in throw TestError.otherError })
            .mapError { $0 as! TestError }
            .subscribe(receiver)

        XCTAssertEqual(receiver.values, [])
        XCTAssertEqual(receiver.completion, [.finished])

        publisher = TestPublisher.success(["Hello"])
        receiver = TestSubject()
        subscription = publisher
            .tryMin(by: { _, _ in throw TestError.otherError })
            .mapError { $0 as! TestError }
            .subscribe(receiver)

        XCTAssertEqual(receiver.values, ["Hello"])
        XCTAssertEqual(receiver.completion, [.finished])

        publisher = TestPublisher.success(["Hello", "World"])
        receiver = TestSubject()
        subscription = publisher
            .tryMin(by: { _, _ in throw TestError.otherError })
            .mapError { $0 as! TestError }
            .subscribe(receiver)

        XCTAssertEqual(receiver.values, [])
        XCTAssertEqual(receiver.completion, [.failure(.otherError)])

        publisher = TestPublisher(.success("Hello"), .success("World"), .failure(.error))
        receiver = TestSubject()
        subscription = publisher
            .tryMin(by: { _, _ in throw TestError.otherError })
            .mapError { $0 as! TestError }
            .subscribe(receiver)

        XCTAssertEqual(receiver.values, [])
        XCTAssertEqual(receiver.completion, [.failure(.otherError)])

        _ = subscription
    }

    func testMax() {
        var publisher: TestPublisher<String, TestError>
        var receiver: TestSubject<String, TestError>
        var subscription: AnyCancellable

        publisher = TestPublisher.success([])
        receiver = TestSubject()
        subscription = publisher
            .max()
            .subscribe(receiver)

        XCTAssertEqual(receiver.values, [])
        XCTAssertEqual(receiver.completion, [.finished])

        publisher = TestPublisher.success(["Hello"])
        receiver = TestSubject()
        subscription = publisher
            .max()
            .subscribe(receiver)

        XCTAssertEqual(receiver.values, ["Hello"])
        XCTAssertEqual(receiver.completion, [.finished])

        publisher = TestPublisher.success(["Hello", "World"])
        receiver = TestSubject()
        subscription = publisher
            .max()
            .subscribe(receiver)

        XCTAssertEqual(receiver.values, ["World"])
        XCTAssertEqual(receiver.completion, [.finished])

        publisher = TestPublisher(.success("Hello"), .success("World"), .failure(.error))
        receiver = TestSubject()
        subscription = publisher
            .max()
            .subscribe(receiver)

        XCTAssertEqual(receiver.values, [])
        XCTAssertEqual(receiver.completion, [.failure(.error)])

        publisher = TestPublisher.success([])
        receiver = TestSubject()
        subscription = publisher
            .max(by: >)
            .subscribe(receiver)

        XCTAssertEqual(receiver.values, [])
        XCTAssertEqual(receiver.completion, [.finished])

        publisher = TestPublisher.success(["Hello"])
        receiver = TestSubject()
        subscription = publisher
            .max(by: >)
            .subscribe(receiver)

        XCTAssertEqual(receiver.values, ["Hello"])
        XCTAssertEqual(receiver.completion, [.finished])

        publisher = TestPublisher.success(["Hello", "World"])
        receiver = TestSubject()
        subscription = publisher
            .max(by: >)
            .subscribe(receiver)

        XCTAssertEqual(receiver.values, ["Hello"])
        XCTAssertEqual(receiver.completion, [.finished])

        publisher = TestPublisher(.success("Hello"), .success("World"), .failure(.error))
        receiver = TestSubject()
        subscription = publisher
            .max(by: >)
            .subscribe(receiver)

        XCTAssertEqual(receiver.values, [])
        XCTAssertEqual(receiver.completion, [.failure(.error)])

        publisher = TestPublisher.success([])
        receiver = TestSubject()
        subscription = publisher
            .tryMax(by: >)
            .mapError { $0 as! TestError }
            .subscribe(receiver)

        XCTAssertEqual(receiver.values, [])
        XCTAssertEqual(receiver.completion, [.finished])

        publisher = TestPublisher.success(["Hello"])
        receiver = TestSubject()
        subscription = publisher
            .tryMax(by: >)
            .mapError { $0 as! TestError }
            .subscribe(receiver)

        XCTAssertEqual(receiver.values, ["Hello"])
        XCTAssertEqual(receiver.completion, [.finished])

        publisher = TestPublisher.success(["Hello", "World"])
        receiver = TestSubject()
        subscription = publisher
            .tryMax(by: >)
            .mapError { $0 as! TestError }
            .subscribe(receiver)

        XCTAssertEqual(receiver.values, ["Hello"])
        XCTAssertEqual(receiver.completion, [.finished])

        publisher = TestPublisher(.success("Hello"), .success("World"), .failure(.error))
        receiver = TestSubject()
        subscription = publisher
            .tryMax(by: >)
            .mapError { $0 as! TestError }
            .subscribe(receiver)

        XCTAssertEqual(receiver.values, [])
        XCTAssertEqual(receiver.completion, [.failure(.error)])

        publisher = TestPublisher.success([])
        receiver = TestSubject()
        subscription = publisher
            .tryMax(by: { _, _ in throw TestError.otherError })
            .mapError { $0 as! TestError }
            .subscribe(receiver)

        XCTAssertEqual(receiver.values, [])
        XCTAssertEqual(receiver.completion, [.finished])

        publisher = TestPublisher.success(["Hello"])
        receiver = TestSubject()
        subscription = publisher
            .tryMax(by: { _, _ in throw TestError.otherError })
            .mapError { $0 as! TestError }
            .subscribe(receiver)

        XCTAssertEqual(receiver.values, ["Hello"])
        XCTAssertEqual(receiver.completion, [.finished])

        publisher = TestPublisher.success(["Hello", "World"])
        receiver = TestSubject()
        subscription = publisher
            .tryMax(by: { _, _ in throw TestError.otherError })
            .mapError { $0 as! TestError }
            .subscribe(receiver)

        XCTAssertEqual(receiver.values, [])
        XCTAssertEqual(receiver.completion, [.failure(.otherError)])

        publisher = TestPublisher(.success("Hello"), .success("World"), .failure(.error))
        receiver = TestSubject()
        subscription = publisher
            .tryMax(by: { _, _ in throw TestError.otherError })
            .mapError { $0 as! TestError }
            .subscribe(receiver)

        XCTAssertEqual(receiver.values, [])
        XCTAssertEqual(receiver.completion, [.failure(.otherError)])

        _ = subscription
    }
}
