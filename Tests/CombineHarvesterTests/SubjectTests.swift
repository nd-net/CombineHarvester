//
//  SubjectTests.swift
//  CombineHarvesterTests
//
//  Created by Andreas Hartl on 14.06.19.
//

import XCTest
@testable import CombineHarvester

class SubjectTests: XCTestCase {
    func testSubscribeToSubject() {
        let subject = TestSubject()
        let publisher = TestSubject()

        let cancellable = publisher.subscribe(subject)
        publisher.send("Hello")
        publisher.send("World")
        publisher.send(completion: .finished)
        _ = cancellable

        XCTAssertEqual(subject.values, ["Hello", "World"])
        XCTAssertEqual(subject.completion, [.finished])
    }

    func testSubscribeToSubjectAndCancel() {
        let subject = TestSubject()
        let publisher = TestSubject()

        let cancellable = publisher.subscribe(subject)
        publisher.send("Hello")
        publisher.send("World")
        cancellable.cancel()
        publisher.send("Hello again")

        XCTAssertEqual(subject.values, ["Hello", "World"])
        XCTAssertEqual(subject.completion, [])
    }
}
