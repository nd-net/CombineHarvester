//
//  AllSatisfyTests.swift
//  CombineHarvesterTests
//
//  Created by Andreas Hartl on 25.06.19.
//

import XCTest

class AllSatisfyTests: XCTestCase {
    func testAllSatisfy() {
        let lorem = ["Lorem", "ipsum", "dolor", "sit", "amet"]
        let tests = (0..<lorem.count).map { Array(lorem[..<$0]) }
        var publisher: TestPublisher<String, TestError>
        var receiver: TestSubject<Bool, TestError>

        for sequence in tests {
            publisher = TestPublisher.success(sequence)
            receiver = TestSubject()
            _ = publisher.allSatisfy { !$0.isEmpty }.subscribe(receiver)

            XCTAssertEqual(receiver.values, [true])
            XCTAssertEqual(receiver.completion, [.finished])

            publisher = TestPublisher(sequence.map(Result.success) + [.failure(.error)])
            receiver = TestSubject()
            _ = publisher.allSatisfy { !$0.isEmpty }.subscribe(receiver)

            XCTAssertEqual(receiver.values, [])
            XCTAssertEqual(receiver.completion, [.failure(.error)])

            publisher = TestPublisher.success(sequence)
            receiver = TestSubject()
            _ = publisher.allSatisfy { $0 != "dolor" }.subscribe(receiver)

            XCTAssertEqual(receiver.values, [sequence.count <= 2 ? true : false])
            XCTAssertEqual(receiver.completion, [.finished])

            publisher = TestPublisher(sequence.map(Result.success) + [.failure(.error)])
            receiver = TestSubject()
            _ = publisher.allSatisfy { $0 != "dolor" }.subscribe(receiver)

            XCTAssertEqual(receiver.values, sequence.count <= 2 ? [] : [false])
            XCTAssertEqual(receiver.completion, [sequence.count <= 2 ? .failure(.error) : .finished])

            publisher = TestPublisher.success(sequence)
            receiver = TestSubject()
            _ = publisher
                .tryAllSatisfy {
                    if $0 == "dolor" {
                        throw TestError.otherError
                    }
                    return true
                }
                .mapError { $0 as! TestError }
                .subscribe(receiver)

            XCTAssertEqual(receiver.values, sequence.count <= 2 ? [true] : [])
            XCTAssertEqual(receiver.completion, sequence.count <= 2 ? [.finished] : [.failure(.otherError)])

            publisher = TestPublisher(sequence.map(Result.success) + [.failure(.error)])
            receiver = TestSubject()
            _ = publisher
                .tryAllSatisfy {
                    if $0 == "dolor" {
                        throw TestError.otherError
                    }
                    return true
                }
                .mapError { $0 as! TestError }
                .subscribe(receiver)

            XCTAssertEqual(receiver.values, [])
            XCTAssertEqual(receiver.completion, sequence.count <= 2 ? [.failure(.error)] : [.failure(.otherError)])
        }
    }
}
