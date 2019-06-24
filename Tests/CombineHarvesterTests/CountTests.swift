//
//  CountTests.swift
//  CombineHarvesterTests
//
//  Created by Andreas Hartl on 24.06.19.
//

import CombineHarvester
import XCTest

class CountTests: XCTestCase {
    func testCount() {
        var publisher = TestPublisher((0..<100).compactMap { Result<Int, TestError>.success($0) })
            .count()
        var receiver = TestSubject<Int, TestError>()

        var subscription = publisher.subscribe(receiver)

        XCTAssertEqual(receiver.values, [100])
        XCTAssertEqual(receiver.completion, [.finished])

        publisher = TestPublisher()
            .count()
        receiver = TestSubject<Int, TestError>()

        subscription = publisher.subscribe(receiver)

        XCTAssertEqual(receiver.values, [0])
        XCTAssertEqual(receiver.completion, [.finished])

        publisher = TestPublisher(.failure(.error))
            .count()
        receiver = TestSubject<Int, TestError>()

        subscription = publisher.subscribe(receiver)

        XCTAssertEqual(receiver.values, [])
        XCTAssertEqual(receiver.completion, [.failure(.error)])

        publisher = TestPublisher(.success(1), .failure(.error))
            .count()
        receiver = TestSubject<Int, TestError>()

        subscription = publisher.subscribe(receiver)

        XCTAssertEqual(receiver.values, [])
        XCTAssertEqual(receiver.completion, [.failure(.error)])

        receiver = TestSubject<Int, TestError>()

        subscription = Publishers.Empty(completeImmediately: true, outputType: Int.self, failureType: TestError.self)
            .count()
            .subscribe(receiver)

        XCTAssertEqual(receiver.values, [0])
        XCTAssertEqual(receiver.completion, [.finished])

        receiver = TestSubject<Int, TestError>()

        subscription = Publishers.Empty(completeImmediately: false, outputType: Int.self, failureType: TestError.self)
            .count()
            .subscribe(receiver)

        XCTAssertEqual(receiver.values, [])
        XCTAssertEqual(receiver.completion, [])

        _ = subscription
    }
}
