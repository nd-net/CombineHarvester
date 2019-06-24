//
//  IgnoreOutputTests.swift
//  CombineHarvesterTests
//
//  Created by Andreas Hartl on 24.06.19.
//

import XCTest
@testable import CombineHarvester

class IgnoreOutputTests: XCTestCase {
    let success = (0..<9).map { s -> Result<String, TestError> in .success("\(s)") }

    func testIgnoreOutput() {
        var subject = TestSubject<Never, TestError>()
        _ = TestPublisher(success)
            .ignoreOutput()
            .subscribe(subject)

        XCTAssertEqual(subject.values, [])
        XCTAssertEqual(subject.completion, [.finished])

        subject = TestSubject()
        _ = TestPublisher(self.success + [.failure(.error)])
            .ignoreOutput()
            .subscribe(subject)

        XCTAssertEqual(subject.values, [])
        XCTAssertEqual(subject.completion, [.failure(.error)])

        subject = TestSubject()
        _ = Publishers.Empty(completeImmediately: false, outputType: String.self, failureType: TestError.self)
            .ignoreOutput()
            .subscribe(subject)

        XCTAssertEqual(subject.values, [])
        XCTAssertEqual(subject.completion, [])
    }
}
