//
//  ReduceTests.swift
//  CombineHarvesterTests
//
//  Created by Andreas Hartl on 25.06.19.
//

import XCTest
@testable import CombineHarvester

class ReduceTests: XCTestCase {
    func testReduce() {
        let lorem = ["Lorem", "ipsum", "dolor", "sit", "amet"]
        let tests = (0..<lorem.count).map { Array(lorem[..<$0]) }
        var publisher: TestPublisher<String, TestError>
        var receiver: TestSubject<String, TestError>

        for sequence in tests {
            publisher = TestPublisher.success(sequence)
            receiver = TestSubject()
            _ = publisher
                .reduce("") { $0 + $1 }
                .subscribe(receiver)

            XCTAssertEqual(receiver.values, sequence.isEmpty ? [] : [sequence.joined()])
            XCTAssertEqual(receiver.completion, [.finished])
        }

        for sequence in tests {
            publisher = TestPublisher(sequence.map(Result.success) + [.failure(.error)])
            receiver = TestSubject()
            _ = publisher
                .reduce("") { $0 + $1 }
                .subscribe(receiver)

            XCTAssertEqual(receiver.values, [])
            XCTAssertEqual(receiver.completion, [.failure(.error)])
        }
    }

    func testTryReduce() {
        let lorem = ["Lorem", "ipsum", "dolor", "sit", "amet"]
        let tests = (0..<lorem.count).map { Array(lorem[..<$0]) }
        var publisher: TestPublisher<String, TestError>
        var receiver: TestSubject<String, TestError>

        for sequence in tests {
            publisher = TestPublisher.success(sequence)
            receiver = TestSubject()
            _ = publisher
                .tryReduce("") { $0 + $1 }
                .mapError { $0 as! TestError }
                .subscribe(receiver)

            XCTAssertEqual(receiver.values, sequence.isEmpty ? [] : [sequence.joined()])
            XCTAssertEqual(receiver.completion, [.finished])
        }

        for sequence in tests {
            publisher = TestPublisher(sequence.map(Result.success) + [.failure(.error)])
            receiver = TestSubject()
            _ = publisher
                .tryReduce("") { $0 + $1 }
                .mapError { $0 as! TestError }
                .subscribe(receiver)

            XCTAssertEqual(receiver.values, [])
            XCTAssertEqual(receiver.completion, [.failure(.error)])
        }

        for sequence in tests {
            publisher = TestPublisher.success(sequence)
            receiver = TestSubject()
            _ = publisher
                .tryReduce("") { _, _ in throw TestError.error }
                .mapError { $0 as! TestError }
                .subscribe(receiver)

            XCTAssertEqual(receiver.values, [])
            XCTAssertEqual(receiver.completion, sequence.isEmpty ? [.finished] : [.failure(.error)])
        }
    }
}
