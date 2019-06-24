//
//  FirstTests.swift
//  CombineHarvesterTests
//
//  Created by Andreas Hartl on 24.06.19.
//

import XCTest

class FirstTests: XCTestCase {
    typealias TPublisher = TestPublisher<String, TestError>

    func testFirst() {
        var publisher = TPublisher()
        var receiver = TestSubject<String, TestError>()

        var subscription = publisher
            .first()
            .subscribe(receiver)

        XCTAssertEqual(receiver.values, [])
        XCTAssertEqual(receiver.completion, [.finished])

        publisher = TPublisher(.success("Hello"))
        receiver = TestSubject<String, TestError>()

        subscription = publisher
            .first()
            .subscribe(receiver)

        XCTAssertEqual(receiver.values, ["Hello"])
        XCTAssertEqual(receiver.completion, [.finished])

        publisher = TPublisher(.success("Hello"), .success("World"))
        receiver = TestSubject<String, TestError>()

        subscription = publisher
            .first()
            .subscribe(receiver)

        XCTAssertEqual(receiver.values, ["Hello"])
        XCTAssertEqual(receiver.completion, [.finished])

        publisher = TPublisher(.failure(.error))
        receiver = TestSubject<String, TestError>()

        subscription = publisher
            .first()
            .subscribe(receiver)

        XCTAssertEqual(receiver.values, [])
        XCTAssertEqual(receiver.completion, [.failure(.error)])

        publisher = TPublisher(.success("Hello"), .failure(.error))
        receiver = TestSubject<String, TestError>()

        subscription = publisher
            .first()
            .subscribe(receiver)

        XCTAssertEqual(receiver.values, ["Hello"])
        XCTAssertEqual(receiver.completion, [.finished])

        _ = subscription
    }

    func testFirstWhere() {
        var publisher = TPublisher()
        var receiver = TestSubject<String, TestError>()

        var subscription = publisher
            .first { $0 == "World" }
            .subscribe(receiver)

        XCTAssertEqual(receiver.values, [])
        XCTAssertEqual(receiver.completion, [.finished])

        publisher = TPublisher(.success("Hello"))
        receiver = TestSubject<String, TestError>()

        subscription = publisher
            .first { $0 == "World" }
            .subscribe(receiver)

        XCTAssertEqual(receiver.values, [])
        XCTAssertEqual(receiver.completion, [.finished])

        publisher = TPublisher(.success("Hello"), .success("World"))
        receiver = TestSubject<String, TestError>()

        subscription = publisher
            .first { $0 == "World" }
            .subscribe(receiver)

        XCTAssertEqual(receiver.values, ["World"])
        XCTAssertEqual(receiver.completion, [.finished])

        publisher = TPublisher(.success("Hello"), .success("World"), .success("Foo"))
        receiver = TestSubject<String, TestError>()

        subscription = publisher
            .first { $0 == "World" }
            .subscribe(receiver)

        XCTAssertEqual(receiver.values, ["World"])
        XCTAssertEqual(receiver.completion, [.finished])

        publisher = TPublisher(.failure(.error))
        receiver = TestSubject<String, TestError>()

        subscription = publisher
            .first { $0 == "World" }
            .subscribe(receiver)

        XCTAssertEqual(receiver.values, [])
        XCTAssertEqual(receiver.completion, [.failure(.error)])

        publisher = TPublisher(.success("Hello"), .failure(.error))
        receiver = TestSubject<String, TestError>()

        subscription = publisher
            .first { $0 == "World" }
            .subscribe(receiver)

        XCTAssertEqual(receiver.values, [])
        XCTAssertEqual(receiver.completion, [.failure(.error)])

        publisher = TPublisher(.success("Hello"), .success("World"), .failure(.error))
        receiver = TestSubject<String, TestError>()

        subscription = publisher
            .first { $0 == "World" }
            .subscribe(receiver)

        XCTAssertEqual(receiver.values, ["World"])
        XCTAssertEqual(receiver.completion, [.finished])

        _ = subscription
    }

    func testTryFirstWhere() {
        var publisher = TPublisher()
        var receiver = TestSubject<String, TestError>()

        var subscription = publisher
            .tryFirst { $0 == "World" }
            .mapError { $0 as! TestError }
            .subscribe(receiver)

        XCTAssertEqual(receiver.values, [])
        XCTAssertEqual(receiver.completion, [.finished])

        publisher = TPublisher(.success("Hello"))
        receiver = TestSubject<String, TestError>()

        subscription = publisher
            .tryFirst { $0 == "World" }
            .mapError { $0 as! TestError }
            .subscribe(receiver)

        XCTAssertEqual(receiver.values, [])
        XCTAssertEqual(receiver.completion, [.finished])

        publisher = TPublisher(.success("Hello"), .success("World"))
        receiver = TestSubject<String, TestError>()

        subscription = publisher
            .tryFirst { $0 == "World" }
            .mapError { $0 as! TestError }
            .subscribe(receiver)

        XCTAssertEqual(receiver.values, ["World"])
        XCTAssertEqual(receiver.completion, [.finished])

        publisher = TPublisher(.success("Hello"), .success("World"), .success("Foo"))
        receiver = TestSubject<String, TestError>()

        subscription = publisher
            .tryFirst { $0 == "World" }
            .mapError { $0 as! TestError }
            .subscribe(receiver)

        XCTAssertEqual(receiver.values, ["World"])
        XCTAssertEqual(receiver.completion, [.finished])

        publisher = TPublisher(.failure(.error))
        receiver = TestSubject<String, TestError>()

        subscription = publisher
            .tryFirst { $0 == "World" }
            .mapError { $0 as! TestError }
            .subscribe(receiver)

        XCTAssertEqual(receiver.values, [])
        XCTAssertEqual(receiver.completion, [.failure(.error)])

        publisher = TPublisher(.success("Hello"), .failure(.error))
        receiver = TestSubject<String, TestError>()

        subscription = publisher
            .tryFirst { $0 == "World" }
            .mapError { $0 as! TestError }
            .subscribe(receiver)

        XCTAssertEqual(receiver.values, [])
        XCTAssertEqual(receiver.completion, [.failure(.error)])

        publisher = TPublisher(.success("Hello"), .success("World"), .failure(.error))
        receiver = TestSubject<String, TestError>()

        subscription = publisher
            .tryFirst { $0 == "World" }
            .mapError { $0 as! TestError }
            .subscribe(receiver)

        XCTAssertEqual(receiver.values, ["World"])
        XCTAssertEqual(receiver.completion, [.finished])

        publisher = TPublisher(.success("Hello"), .success("World"), .failure(.error))
        receiver = TestSubject<String, TestError>()

        subscription = publisher
            .tryFirst { _ in throw TestError.otherError }
            .mapError { $0 as! TestError }
            .subscribe(receiver)

        XCTAssertEqual(receiver.values, [])
        XCTAssertEqual(receiver.completion, [.failure(.otherError)])

        _ = subscription
    }
}
