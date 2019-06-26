//
//  OuputTests.swift
//  CombineHarvesterTests
//
//  Created by Andreas Hartl on 26.06.19.
//

import XCTest
@testable import CombineHarvester

class OuputTests: XCTestCase {
    func testOutputAt() {
        let lorem = ["Lorem", "ipsum", "dolor", "sit", "amet"]
        let tests = (0..<lorem.count).map { Array(lorem[..<$0]) }
        var publisher: TestPublisher<String, TestError>
        var receiver: TestSubject<String, TestError>

        for sequence in tests {
            publisher = TestPublisher.success(sequence)
            receiver = TestSubject()
            _ = publisher.output(at: 0)
                .subscribe(receiver)

            XCTAssertEqual(receiver.values, sequence.isEmpty ? [] : ["Lorem"])
            XCTAssertEqual(receiver.completion, [.finished])

            publisher = TestPublisher.success(sequence)
            receiver = TestSubject()
            _ = publisher.output(at: -1)
                .subscribe(receiver)

            XCTAssertEqual(receiver.values, [])
            XCTAssertEqual(receiver.completion, [.finished])

            publisher = TestPublisher.success(sequence)
            receiver = TestSubject()
            _ = publisher.output(at: 3)
                .subscribe(receiver)

            XCTAssertEqual(receiver.values, sequence.count > 3 ? [sequence[3]] : [])
            XCTAssertEqual(receiver.completion, [.finished])

            publisher = TestPublisher(sequence.map(Result.success) + [.failure(TestError.error)])
            receiver = TestSubject()
            _ = publisher.output(at: 3)
                .subscribe(receiver)

            XCTAssertEqual(receiver.values, sequence.count > 3 ? [sequence[3]] : [])
            XCTAssertEqual(receiver.completion, sequence.count > 3 ? [.finished] : [.failure(.error)])
        }
    }

    func testOutputIn() {
        let lorem = ["Lorem", "ipsum", "dolor", "sit", "amet"]
        let tests = (0..<lorem.count).map { Array(lorem[..<$0]) }
        var publisher: TestPublisher<String, TestError>
        var receiver: TestSubject<String, TestError>

        for sequence in tests {
            publisher = TestPublisher.success(sequence)
            receiver = TestSubject()
            _ = publisher.output(in: 0...0)
                .subscribe(receiver)

            XCTAssertEqual(receiver.values, sequence.isEmpty ? [] : ["Lorem"])
            XCTAssertEqual(receiver.completion, [.finished])

            publisher = TestPublisher.success(sequence)
            receiver = TestSubject()
            _ = publisher.output(in: ..<0)
                .subscribe(receiver)

            XCTAssertEqual(receiver.values, [])
            XCTAssertEqual(receiver.completion, [.finished])

            publisher = TestPublisher.success(sequence)
            receiver = TestSubject()
            _ = publisher.output(in: 1...)
                .subscribe(receiver)

            XCTAssertEqual(receiver.values, sequence.count < 2 ? [] : Array(sequence[1...]))
            XCTAssertEqual(receiver.completion, [.finished])

            publisher = TestPublisher.success(sequence)
            receiver = TestSubject()
            _ = publisher.output(in: 1..<3)
                .subscribe(receiver)

            let expected: [String]
            switch sequence.count {
            case 0:
                expected = []
            case 1, 2:
                expected = Array(sequence[1...])
            default:
                expected = Array(sequence[1..<3])
            }
            XCTAssertEqual(receiver.values, expected)
            XCTAssertEqual(receiver.completion, [.finished])

            publisher = TestPublisher(sequence.map(Result.success) + [.failure(TestError.error)])
            receiver = TestSubject()
            _ = publisher.output(in: 3..<4)
                .subscribe(receiver)

            XCTAssertEqual(receiver.values, sequence.count > 3 ? [sequence[3]] : [])
            XCTAssertEqual(receiver.completion, sequence.count > 3 ? [.finished] : [.failure(.error)])
        }
    }

    func testPrefix() {
        let lorem = ["Lorem", "ipsum", "dolor", "sit", "amet"]
        let tests = (0..<lorem.count).map { Array(lorem[..<$0]) }
        var publisher: TestPublisher<String, TestError>
        var receiver: TestSubject<String, TestError>

        for sequence in tests {
            publisher = TestPublisher.success(sequence)
            receiver = TestSubject()
            _ = publisher.prefix(0)
                .subscribe(receiver)

            XCTAssertEqual(receiver.values, [])
            XCTAssertEqual(receiver.completion, [.finished])

            publisher = TestPublisher.success(sequence)
            receiver = TestSubject()
            _ = publisher.output(at: 3)
                .subscribe(receiver)

            XCTAssertEqual(receiver.values, sequence.count > 3 ? [sequence[3]] : [])
            XCTAssertEqual(receiver.completion, [.finished])

            publisher = TestPublisher(sequence.map(Result.success) + [.failure(TestError.error)])
            receiver = TestSubject()
            _ = publisher.prefix(3)
                .subscribe(receiver)

            XCTAssertEqual(receiver.values, sequence.count > 3 ? Array(sequence[..<3]) : sequence)
            XCTAssertEqual(receiver.completion, sequence.count >= 3 ? [.finished] : [.failure(.error)], "Testing \(sequence)")
        }
    }
}
