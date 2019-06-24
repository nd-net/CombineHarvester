//
//  DeferedTests.swift
//  CombineHarvesterTests
//
//  Created by Andreas Hartl on 24.06.19.
//

import XCTest
@testable import CombineHarvester

class DeferedTests: XCTestCase {
    var deferedPublisher: TestPublisher<String, TestError>?

    override func setUp() {
        self.deferedPublisher = nil
    }

    func createTestPublisher() -> TestPublisher<String, TestError> {
        let result = TestPublisher<String, TestError>([.success("Hello")])
        self.deferedPublisher = result
        return result
    }

    func testDeferedPublisherWithSubscription() {
        let subject = TestSubject<String, TestError>()
        _ = Publishers.Deferred(createPublisher: self.createTestPublisher)
            .subscribe(subject)

        XCTAssertEqual(subject.values, ["Hello"])
        XCTAssertEqual(subject.completion, [.finished])
        XCTAssertNotNil(self.deferedPublisher)
    }

    func testDeferedPublisherWithoutSubscription() {
        _ = Publishers.Deferred(createPublisher: self.createTestPublisher)
        XCTAssertNil(self.deferedPublisher)
    }
}
