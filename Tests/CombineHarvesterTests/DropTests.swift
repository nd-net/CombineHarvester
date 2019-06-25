//
//  DropTests.swift
//  CombineHarvesterTests
//
//  Created by Andreas Hartl on 25.06.19.
//

import XCTest

class DropTests: XCTestCase {
    func testDrop() {
        let lorem = ["Lorem", "ipsum", "dolor", "sit", "amet"]
        let tests = (0..<lorem.count).map { Array(lorem[..<$0]) }
        var publisher: TestPublisher<String, TestError>
        var receiver: TestSubject<String, TestError>

        for sequence in tests {
            publisher = TestPublisher.success(sequence)
            receiver = TestSubject()
            _ = publisher.dropFirst(-5).subscribe(receiver)

            XCTAssertEqual(receiver.values, sequence)
            XCTAssertEqual(receiver.completion, [.finished])
        }

        for sequence in tests {
            publisher = TestPublisher.success(sequence)
            receiver = TestSubject()
            _ = publisher.dropFirst(0).subscribe(receiver)

            XCTAssertEqual(receiver.values, sequence)
            XCTAssertEqual(receiver.completion, [.finished])
        }

        for sequence in tests {
            publisher = TestPublisher.success(sequence)
            receiver = TestSubject()
            _ = publisher.dropFirst().subscribe(receiver)

            XCTAssertEqual(receiver.values, Array(sequence.dropFirst()))
            XCTAssertEqual(receiver.completion, [.finished])
        }

        for sequence in tests {
            publisher = TestPublisher.success(sequence)
            receiver = TestSubject()
            _ = publisher.dropFirst(2).subscribe(receiver)

            XCTAssertEqual(receiver.values, Array(sequence.dropFirst(2)))
            XCTAssertEqual(receiver.completion, [.finished])
        }
        for sequence in tests {
            publisher = TestPublisher.success(sequence)
            receiver = TestSubject()
            _ = publisher.drop(while: lorem[..<2].contains).subscribe(receiver)

            XCTAssertEqual(receiver.values, Array(sequence.dropFirst(2)))
            XCTAssertEqual(receiver.completion, [.finished])
        }

        for sequence in tests {
            publisher = TestPublisher.success(sequence)
            receiver = TestSubject()
            _ = publisher
                .tryDrop(while: lorem[..<2].contains)
                .mapError { $0 as! TestError }
                .subscribe(receiver)

            XCTAssertEqual(receiver.values, Array(sequence.dropFirst(2)))
            XCTAssertEqual(receiver.completion, [.finished])
        }

        for sequence in tests {
            publisher = TestPublisher(sequence.map(Result.success) + [Result.failure(.error)])
            receiver = TestSubject()
            _ = publisher.dropFirst(2).subscribe(receiver)

            XCTAssertEqual(receiver.values, Array(sequence.dropFirst(2)))
            XCTAssertEqual(receiver.completion, [.failure(.error)])

            publisher = TestPublisher(sequence.map(Result.success) + [Result.failure(.error)])
            receiver = TestSubject()
            _ = publisher.drop(while: lorem[..<2].contains).subscribe(receiver)

            XCTAssertEqual(receiver.values, Array(sequence.dropFirst(2)))
            XCTAssertEqual(receiver.completion, [.failure(.error)])

            publisher = TestPublisher.success(sequence)
            receiver = TestSubject()
            _ = publisher
                .tryDrop(while: { _ in throw TestError.otherError })
                .mapError { $0 as! TestError }
                .subscribe(receiver)

            XCTAssertEqual(receiver.values, [])
            XCTAssertEqual(receiver.completion, [sequence.isEmpty ? .finished : .failure(.otherError)])

            publisher = TestPublisher(sequence.map(Result.success) + [Result.failure(.error)])
            receiver = TestSubject()
            _ = publisher
                .tryDrop(while: { _ in throw TestError.otherError })
                .mapError { $0 as! TestError }
                .subscribe(receiver)

            XCTAssertEqual(receiver.values, [])
            XCTAssertEqual(receiver.completion, [sequence.isEmpty ? .failure(.error) : .failure(.otherError)])
        }
    }
}
