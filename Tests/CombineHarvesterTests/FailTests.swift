//
//  FailTests.swift
//  CombineHarvesterTests
//
//  Created by Andreas Hartl on 17.06.19.
//

import XCTest
@testable import CombineHarvester

class FailTests: XCTestCase {
    func testFail() {
        let subject = TestSubject<TestError>()

        let underTest = Publishers.Fail(outputType: String.self, failure: TestError.error)
        _ = underTest.subscribe(subject)

        XCTAssertEqual(subject.values, [])
        XCTAssertEqual(subject.completion, [.failure(TestError.error)])
    }

    func testEquatable() {
        XCTAssertEqual(Publishers.Fail(outputType: String.self, failure: TestError.error), Publishers.Fail(outputType: String.self, failure: TestError.error))
        XCTAssertNotEqual(Publishers.Fail(outputType: String.self, failure: TestError.error), Publishers.Fail(outputType: String.self, failure: TestError.otherError))
    }
}
