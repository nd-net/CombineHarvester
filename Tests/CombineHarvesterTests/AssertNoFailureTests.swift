//
//  AssertNoFailureTests.swift
//  CombineHarvesterTests
//
//  Created by Andreas Hartl on 17.06.19.
//

import XCTest
@testable import CombineHarvester

class AssertNoFailureTests: XCTestCase {
    func testFail() {
        let subject = TestSubject<String, TestError>()
        let receiver = TestSubject<String, Never>()

        let subscription = subject.assertNoFailure("Prefix")
            .subscribe(receiver)

        subject.send("Hello")
        expectFatalError(expectedMessage: "Prefix Received .failure(error)") {
            subject.send(completion: .failure(.error)) // triggers fatal error
        }
        _ = subscription
    }

    func testDoNotFail() {
        let subject = TestSubject<String, TestError>()
        let receiver = TestSubject<String, Never>()

        let subscription = subject.assertNoFailure("Prefix")
            .subscribe(receiver)

        subject.send("Hello")
        subscription.cancel()

        subject.send(completion: .failure(.error)) // Won't trigger anything anymore
    }
}
