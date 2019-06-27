//
//  CurrentValueSubjectTests.swift
//  CombineHarvesterTests
//
//  Created by Andreas Hartl on 27.06.19.
//

import XCTest
@testable import CombineHarvester

class CurrentValueSubjectTests: XCTestCase {
    func testCurrentValueSubject() {
        let publisher = CurrentValueSubject<String, TestError>("Hello")
        let receiver = TestSubject<String, TestError>()

        publisher.value = "World"

        let subscription = publisher.subscribe(receiver)

        XCTAssertEqual(receiver.values, ["World"])

        publisher.value = "Foo"

        XCTAssertEqual(receiver.values, ["World", "Foo"])

        subscription.cancel()

        XCTAssertEqual(receiver.values, ["World", "Foo"])

        publisher.value = "Bar"

        XCTAssertEqual(receiver.values, ["World", "Foo"])

        _ = subscription
    }

    func testCurrentValueSubjectFinishes() {
        let publisher = CurrentValueSubject<String, TestError>("Hello")
        let receiver = TestSubject<String, TestError>()

        publisher.value = "World"

        let subscription = publisher.subscribe(receiver)

        XCTAssertEqual(receiver.values, ["World"])

        publisher.value = "Foo"

        XCTAssertEqual(receiver.values, ["World", "Foo"])

        receiver.send(completion: .finished)

        XCTAssertEqual(receiver.values, ["World", "Foo"])
        XCTAssertEqual(receiver.completion, [.finished])

        publisher.value = "Bar"

        XCTAssertEqual(receiver.values, ["World", "Foo"])

        _ = subscription
    }
}
