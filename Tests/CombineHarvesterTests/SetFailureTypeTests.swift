//
//  SetFailureTypeTests.swift
//  CombineHarvesterTests
//
//  Created by Andreas Hartl on 24.06.19.
//

import XCTest
@testable import CombineHarvester

class SetFailureTypeTests: XCTestCase {
    let hello = [Result<String, Never>.success("Hello")]

    func testSubscribe() {
        let subject = TestSubject<String, TestError>()
        let publisher = TestPublisher(hello)
            .setFailureType(to: TestError.self)
        let cancellable = publisher.subscribe(subject)

        XCTAssertEqual(subject.values, ["Hello"])
        XCTAssertEqual(subject.completion, [.finished])

        _ = cancellable
    }

    func testSetFailureType() {
        XCTAssertEqual(
            TestPublisher(self.hello)
                .setFailureType(to: TestError.self),
            TestPublisher(self.hello)
                .setFailureType(to: TestError.self),
            "Never -> E1"
        )
        XCTAssertEqual(
            TestPublisher(self.hello)
                .setFailureType(to: TestError.self)
                .setFailureType(to: TestError.self),
            TestPublisher(self.hello)
                .setFailureType(to: TestError.self),
            "Never -> E1 -> E1"
        )
        XCTAssertEqual(
            TestPublisher(self.hello)
                .setFailureType(to: NSError.self)
                .setFailureType(to: TestError.self),
            TestPublisher(self.hello)
                .setFailureType(to: TestError.self),
            "Never -> E1 -> E2"
        )
    }
}
