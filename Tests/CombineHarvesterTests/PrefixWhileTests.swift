//
//  PrefixWhileTests.swift
//  CombineHarvesterTests
//
//  Created by Andreas Hartl on 25.06.19.
//

import XCTest
@testable import CombineHarvester

class PrefixWhileTests: XCTestCase {
    func testPrefixWhile() {
        let lorem = ["Lorem", "ipsum", "dolor", "sit", "amet"]
        let tests = (0..<lorem.count).map { Array(lorem[..<$0]) }
        var publisher: TestPublisher<String, TestError>
        var receiver: TestSubject<String, TestError>

        for sequence in tests {
            publisher = TestPublisher.success(sequence)
            receiver = TestSubject()
            _ = publisher.prefix(while: { $0 != "dolor" }).subscribe(receiver)

            XCTAssertEqual(receiver.values, sequence.count < 2 ? sequence : tests[2])
            XCTAssertEqual(receiver.completion, [.finished])

            publisher = TestPublisher(sequence.map(Result.success) + [.failure(.error)])
            receiver = TestSubject()
            _ = publisher.prefix(while: { $0 != "dolor" }).subscribe(receiver)

            XCTAssertEqual(receiver.values, sequence.count <= 2 ? sequence : tests[2])
            XCTAssertEqual(receiver.completion, [sequence.count <= 2 ? .failure(.error) : .finished], "Testing \(sequence)")

            publisher = TestPublisher.success(sequence)
            receiver = TestSubject()
            _ = publisher
                .tryPrefix(while: { $0 != "dolor" })
                .mapError { $0 as! TestError }
                .subscribe(receiver)

            XCTAssertEqual(receiver.values, sequence.count <= 2 ? sequence : tests[2])
            XCTAssertEqual(receiver.completion, [.finished])

            publisher = TestPublisher(sequence.map(Result.success) + [.failure(.error)])
            receiver = TestSubject()
            _ = publisher
                .tryPrefix(while: { $0 != "dolor" })
                .mapError { $0 as! TestError }
                .subscribe(receiver)

            XCTAssertEqual(receiver.values, sequence.count <= 2 ? sequence : tests[2])
            XCTAssertEqual(receiver.completion, [sequence.count <= 2 ? .failure(.error) : .finished])

            publisher = TestPublisher(sequence.map(Result.success) + [.failure(.error)])
            receiver = TestSubject()
            _ = publisher
                .tryPrefix(while: { if $0 == "dolor" {
                    throw TestError.otherError
                    }
                    return true
                })
                .mapError { $0 as! TestError }
                .subscribe(receiver)

            XCTAssertEqual(receiver.values, sequence.count <= 2 ? sequence : tests[2])
            XCTAssertEqual(receiver.completion, [sequence.count <= 2 ? .failure(.error) : .failure(.otherError)])
        }
    }
}
