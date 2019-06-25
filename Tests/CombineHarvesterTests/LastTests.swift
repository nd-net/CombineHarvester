//
//  LastTests.swift
//  CombineHarvesterTests
//
//  Created by Andreas Hartl on 25.06.19.
//

import XCTest

class LastTests: XCTestCase {
    typealias TPublisher = TestPublisher<String, TestError>

    func testLast() {
        var publisher = TPublisher()
        var receiver = TestSubject<String, TestError>()

        var subscription = publisher
            .last()
            .subscribe(receiver)

        XCTAssertEqual(receiver.values, [])
        XCTAssertEqual(receiver.completion, [.finished])

        publisher = TPublisher(.success("Hello"))
        receiver = TestSubject<String, TestError>()

        subscription = publisher
            .last()
            .subscribe(receiver)

        XCTAssertEqual(receiver.values, ["Hello"])
        XCTAssertEqual(receiver.completion, [.finished])

        publisher = TPublisher(.success("Hello"), .success("World"))
        receiver = TestSubject<String, TestError>()

        subscription = publisher
            .last()
            .subscribe(receiver)

        XCTAssertEqual(receiver.values, ["World"])
        XCTAssertEqual(receiver.completion, [.finished])

        publisher = TPublisher(.failure(.error))
        receiver = TestSubject<String, TestError>()

        subscription = publisher
            .last()
            .subscribe(receiver)

        XCTAssertEqual(receiver.values, [])
        XCTAssertEqual(receiver.completion, [.failure(.error)])

        publisher = TPublisher(.success("Hello"), .failure(.error))
        receiver = TestSubject<String, TestError>()

        subscription = publisher
            .last()
            .subscribe(receiver)

        XCTAssertEqual(receiver.values, [])
        XCTAssertEqual(receiver.completion, [.failure(.error)])

        _ = subscription
    }

    func testLastWhere() {
        var publisher = TPublisher()
        var receiver = TestSubject<String, TestError>()

        var subscription = publisher
            .last { $0 == "World" }
            .subscribe(receiver)

        XCTAssertEqual(receiver.values, [])
        XCTAssertEqual(receiver.completion, [.finished])

        publisher = TPublisher(.success("Hello"))
        receiver = TestSubject<String, TestError>()

        subscription = publisher
            .last { $0 == "World" }
            .subscribe(receiver)

        XCTAssertEqual(receiver.values, [])
        XCTAssertEqual(receiver.completion, [.finished])

        publisher = TPublisher(.success("Hello"), .success("World"))
        receiver = TestSubject<String, TestError>()

        subscription = publisher
            .last { $0 == "World" }
            .subscribe(receiver)

        XCTAssertEqual(receiver.values, ["World"])
        XCTAssertEqual(receiver.completion, [.finished])

        publisher = TPublisher(.success("Hello"), .success("World"), .success("Foo"))
        receiver = TestSubject<String, TestError>()

        subscription = publisher
            .last { $0 == "World" }
            .subscribe(receiver)

        XCTAssertEqual(receiver.values, ["World"])
        XCTAssertEqual(receiver.completion, [.finished])

        publisher = TPublisher(.failure(.error))
        receiver = TestSubject<String, TestError>()

        subscription = publisher
            .last { $0 == "World" }
            .subscribe(receiver)

        XCTAssertEqual(receiver.values, [])
        XCTAssertEqual(receiver.completion, [.failure(.error)])

        publisher = TPublisher(.success("Hello"), .failure(.error))
        receiver = TestSubject<String, TestError>()

        subscription = publisher
            .last { $0 == "World" }
            .subscribe(receiver)

        XCTAssertEqual(receiver.values, [])
        XCTAssertEqual(receiver.completion, [.failure(.error)])

        publisher = TPublisher(.success("Hello"), .success("World"), .failure(.error))
        receiver = TestSubject<String, TestError>()

        subscription = publisher
            .last { $0 == "World" }
            .subscribe(receiver)

        XCTAssertEqual(receiver.values, [])
        XCTAssertEqual(receiver.completion, [.failure(.error)])

        _ = subscription
    }

    func testTryLastWhere() {
        var publisher = TPublisher()
        var receiver = TestSubject<String, TestError>()

        var subscription = publisher
            .tryLast { $0 == "World" }
            .mapError { $0 as! TestError }
            .subscribe(receiver)

        XCTAssertEqual(receiver.values, [])
        XCTAssertEqual(receiver.completion, [.finished])

        publisher = TPublisher(.success("Hello"))
        receiver = TestSubject<String, TestError>()

        subscription = publisher
            .tryLast { $0 == "World" }
            .mapError { $0 as! TestError }
            .subscribe(receiver)

        XCTAssertEqual(receiver.values, [])
        XCTAssertEqual(receiver.completion, [.finished])

        publisher = TPublisher(.success("Hello"), .success("World"))
        receiver = TestSubject<String, TestError>()

        subscription = publisher
            .tryLast { $0 == "World" }
            .mapError { $0 as! TestError }
            .subscribe(receiver)

        XCTAssertEqual(receiver.values, ["World"])
        XCTAssertEqual(receiver.completion, [.finished])

        publisher = TPublisher(.success("Hello"), .success("World"), .success("Foo"))
        receiver = TestSubject<String, TestError>()

        subscription = publisher
            .tryLast { $0 == "World" }
            .mapError { $0 as! TestError }
            .subscribe(receiver)

        XCTAssertEqual(receiver.values, ["World"])
        XCTAssertEqual(receiver.completion, [.finished])

        publisher = TPublisher(.failure(.error))
        receiver = TestSubject<String, TestError>()

        subscription = publisher
            .tryLast { $0 == "World" }
            .mapError { $0 as! TestError }
            .subscribe(receiver)

        XCTAssertEqual(receiver.values, [])
        XCTAssertEqual(receiver.completion, [.failure(.error)])

        publisher = TPublisher(.success("Hello"), .failure(.error))
        receiver = TestSubject<String, TestError>()

        subscription = publisher
            .tryLast { $0 == "World" }
            .mapError { $0 as! TestError }
            .subscribe(receiver)

        XCTAssertEqual(receiver.values, [])
        XCTAssertEqual(receiver.completion, [.failure(.error)])

        publisher = TPublisher(.success("Hello"), .success("World"), .failure(.error))
        receiver = TestSubject<String, TestError>()

        subscription = publisher
            .tryLast { $0 == "World" }
            .mapError { $0 as! TestError }
            .subscribe(receiver)

        XCTAssertEqual(receiver.values, [])
        XCTAssertEqual(receiver.completion, [.failure(.error)])

        publisher = TPublisher(.success("Hello"), .success("World"), .failure(.error))
        receiver = TestSubject<String, TestError>()

        subscription = publisher
            .tryLast { _ in throw TestError.otherError }
            .mapError { $0 as! TestError }
            .subscribe(receiver)

        XCTAssertEqual(receiver.values, [])
        XCTAssertEqual(receiver.completion, [.failure(.otherError)])

        _ = subscription
    }
}
