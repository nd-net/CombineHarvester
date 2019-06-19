//
//  MapErrorTests.swift
//  CombineHarvesterTests
//
//  Created by Andreas Hartl on 17.06.19.
//

import XCTest
@testable import CombineHarvester

class MapErrorTests: XCTestCase {
    func testFail() {
        let subject = TestSubject<String, TestError>()
        let receiver = TestSubject<String, TestError>()

        let subscription = subject.mapError { $0 == .error ? .otherError : $0 }
            .subscribe(receiver)

        subject.send("Hello")
        subject.send(completion: .failure(.error))
        _ = subscription

        XCTAssertEqual(receiver.values, ["Hello"])
        XCTAssertEqual(receiver.completion, [.failure(.otherError)])
    }

    func testDoNotFail() {
        let subject = TestSubject<String, TestError>()
        let receiver = TestSubject<String, TestError>()

        let subscription = subject.mapError { $0 == .error ? .otherError : $0 }
            .subscribe(receiver)

        subject.send("Hello")
        subscription.cancel()
        subject.send(completion: .failure(.error))

        XCTAssertEqual(receiver.values, ["Hello"])
        XCTAssertEqual(receiver.completion, [])
    }
}
