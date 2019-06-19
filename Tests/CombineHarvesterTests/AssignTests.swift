//
//  AssignTests.swift
//  CombineHarvesterTests
//
//  Created by Andreas Hartl on 17.06.19.
//

import XCTest
@testable import CombineHarvester

class AssignTests: XCTestCase {
    class Anything {
        var value = ""
    }

    func testAssign() {
        let root = Anything()
        let subject = TestSubject<String, Never>()

        let cancellable = subject.assign(to: \.value, on: root)
        subject.send("ACME Corporation")
        XCTAssertEqual(root.value, "ACME Corporation")

        subject.send("That's all Folks!")
        XCTAssertEqual(root.value, "That's all Folks!")

        cancellable.cancel()

        subject.send("Merry Melodies")
        XCTAssertEqual(root.value, "That's all Folks!", "No update after .cancel()")
    }
}
