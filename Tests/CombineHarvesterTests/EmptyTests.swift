//
//  EmptyTests.swift
//  CombineHarvesterTests
//
//  Created by Andreas Hartl on 17.06.19.
//

import XCTest
@testable import CombineHarvester

class EmptyTests: XCTestCase {
    func testCompleteImmediately() {
        let subject = TestSubject<String, Never>()

        let underTest = Publishers.Empty(completeImmediately: true, outputType: String.self, failureType: Never.self)
        _ = underTest.subscribe(subject)

        XCTAssertEqual(subject.values, [])
        XCTAssertEqual(subject.completion, [.finished])
    }

    func testDoNotCompleteImmediately() {
        let subject = TestSubject<String, Never>()

        let underTest = Publishers.Empty(completeImmediately: false, outputType: String.self, failureType: Never.self)
        _ = underTest.subscribe(subject)

        XCTAssertEqual(subject.values, [])
        XCTAssertEqual(subject.completion, [])
    }
}
