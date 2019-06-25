//
//  ScanTests.swift
//  CombineHarvesterTests
//
//  Created by Andreas Hartl on 25.06.19.
//

import XCTest
@testable import CombineHarvester

class ScanTests: XCTestCase {
    private func scan(_ sequence: [String]) -> [String] {
        if sequence.isEmpty {
            return []
        }
        var result = [String]()
        for index in 0..<sequence.count {
            result.append(sequence[...index].joined())
        }
        return result
    }

    func testScan() {
        let lorem = ["Lorem", "ipsum", "dolor", "sit", "amet"]
        let tests = (0..<lorem.count).map { Array(lorem[..<$0]) }
        var publisher: TestPublisher<String, TestError>
        var receiver: TestSubject<String, TestError>

        for sequence in tests {
            publisher = TestPublisher.success(sequence)
            receiver = TestSubject()
            _ = publisher
                .scan("") { $0 + $1 }
                .subscribe(receiver)

            XCTAssertEqual(receiver.values, self.scan(sequence))
            XCTAssertEqual(receiver.completion, [.finished])
        }

        for sequence in tests {
            publisher = TestPublisher(sequence.map(Result.success) + [.failure(.error)])
            receiver = TestSubject()
            _ = publisher
                .scan("") { $0 + $1 }
                .subscribe(receiver)

            XCTAssertEqual(receiver.values, self.scan(sequence))
            XCTAssertEqual(receiver.completion, [.failure(.error)])
        }

        for sequence in tests {
            publisher = TestPublisher.success(sequence)
            receiver = TestSubject()
            _ = publisher
                .tryScan("") { $0 + $1 }
                .mapError { $0 as! TestError }
                .subscribe(receiver)

            XCTAssertEqual(receiver.values, self.scan(sequence))
            XCTAssertEqual(receiver.completion, [.finished])
        }

        for sequence in tests {
            publisher = TestPublisher(sequence.map(Result.success) + [.failure(.error)])
            receiver = TestSubject()
            _ = publisher
                .tryScan("") { $0 + $1 }
                .mapError { $0 as! TestError }
                .subscribe(receiver)

            XCTAssertEqual(receiver.values, self.scan(sequence))
            XCTAssertEqual(receiver.completion, [.failure(.error)])
        }

        for sequence in tests {
            publisher = TestPublisher(sequence.map(Result.success) + [.failure(.error)])
            receiver = TestSubject()
            _ = publisher
                .tryScan("") { _, _ in throw TestError.otherError }
                .mapError { $0 as! TestError }
                .subscribe(receiver)

            XCTAssertEqual(receiver.values, [])
            XCTAssertEqual(receiver.completion, sequence.isEmpty ? [.failure(.error)] : [.failure(.otherError)])
        }
    }
}
