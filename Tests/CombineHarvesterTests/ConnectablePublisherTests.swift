//
//  ConnectablePublisherTests.swift
//  CombineHarvesterTests
//
//  Created by Andreas Hartl on 27.06.19.
//

import CombineHarvester
import XCTest

class ConnectablePublisherTests: XCTestCase {
    func testCurrentValueSubject() {
        let subject = CurrentValueSubject<String, Never>("Hello")
        let publisher = subject.makeConnectable()
        let receiver = TestSubject<String, Never>()

        subject.value = "World"

        let subscription = publisher.subscribe(receiver)

        XCTAssertEqual(receiver.values, [])
        let connection = publisher.connect()

        subject.value = "Foo"

        XCTAssertEqual(receiver.values, ["Foo"])

        subject.value = "Bar"

        XCTAssertEqual(receiver.values, ["Foo", "Bar"])

        connection.cancel()

        subject.value = "Baz"

        XCTAssertEqual(receiver.values, ["Foo", "Bar"])

        _ = subscription
    }
}
