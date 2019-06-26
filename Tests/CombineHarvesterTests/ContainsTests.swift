//
//  ContainsTests.swift
//  CombineHarvesterTests
//
//  Created by Andreas Hartl on 26.06.19.
//

import XCTest

class ContainsTests: XCTestCase {
    func testContains() {
        let lorem = ["Lorem", "ipsum", "dolor", "sit", "amet"]
        let tests = (0..<lorem.count).map { Array(lorem[..<$0]) }
        var publisher: TestPublisher<String, TestError>
        var receiver: TestSubject<Bool, TestError>

        for sequence in tests {
            publisher = TestPublisher.success(sequence)
            receiver = TestSubject()
            _ = publisher.contains("ipsum").subscribe(receiver)

            XCTAssertEqual(receiver.values, [sequence.contains("ipsum")])
            XCTAssertEqual(receiver.completion, [.finished])

            publisher = TestPublisher.success(sequence)
            receiver = TestSubject()
            _ = publisher.contains { $0 == "ipsum" }.subscribe(receiver)

            XCTAssertEqual(receiver.values, [sequence.contains("ipsum")])
            XCTAssertEqual(receiver.completion, [.finished])

            publisher = TestPublisher(sequence.map(Result.success) + [.failure(.error)])
            receiver = TestSubject()
            _ = publisher.contains { $0 == "ipsum" }.subscribe(receiver)

            XCTAssertEqual(receiver.values, sequence.contains("ipsum") ? [true] : [])
            XCTAssertEqual(receiver.completion, sequence.contains("ipsum") ? [.finished] : [.failure(.error)])

            publisher = TestPublisher.success(sequence)
            receiver = TestSubject()
            _ = publisher.contains { $0 == "dolor" }.subscribe(receiver)

            XCTAssertEqual(receiver.values, [sequence.contains("dolor")])
            XCTAssertEqual(receiver.completion, [.finished])

            publisher = TestPublisher.success(sequence)
            receiver = TestSubject()
            _ = publisher
                .tryContains {
                    if $0 == "dolor" {
                        throw TestError.otherError
                    }
                    return false
                }
                .mapError { $0 as! TestError }
                .subscribe(receiver)

            XCTAssertEqual(receiver.values, sequence.contains("dolor") ? [] : [false], "Testing \(sequence)")
            XCTAssertEqual(receiver.completion, sequence.contains("dolor") ? [.failure(.otherError)] : [.finished], "Testing \(sequence)")

            publisher = TestPublisher(sequence.map(Result.success) + [.failure(.error)])
            receiver = TestSubject()
            _ = publisher
                .tryContains {
                    if $0 == "dolor" {
                        throw TestError.otherError
                    }
                    return false
                }
                .mapError { $0 as! TestError }
                .subscribe(receiver)

            XCTAssertEqual(receiver.values, [], "Testing \(sequence)")
            XCTAssertEqual(receiver.completion, sequence.contains("dolor") ? [.failure(.otherError)] : [.failure(.error)], "Testing \(sequence)")
        }
    }
}
