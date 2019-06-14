//
//  CombineIdentifierTests.swift
//  CombineHarvesterTests
//
//  Created by Andreas Hartl on 14.06.19.
//

import XCTest
@testable import CombineHarvester

class CombineIdentifierTests: XCTestCase {
    func testEquality() {
        XCTAssertNotEqual(CombineIdentifier(), CombineIdentifier(), "Two anonymous combine identifiers are not equal to each other")
        let obj1 = "obj1" as NSString
        let obj2 = "obj2" as NSString
        XCTAssertNotEqual(CombineIdentifier(obj1), CombineIdentifier(obj2), "Two combine identifiers with different objects are not equal to each other")
        XCTAssertNotEqual(CombineIdentifier(obj1), CombineIdentifier(obj2), "An anonymous combine identifier and a combine identifier with an object are not equal to each other")
        XCTAssertEqual(CombineIdentifier(obj1), CombineIdentifier(obj1), "Two combine identifiers with same objects are equal to each other")
    }

    func testDescription() {
        class Empty {
        }

        XCTAssertEqual(CombineIdentifier().description, "<anonymous>")
        XCTAssertEqual(CombineIdentifier("obj" as NSString).description, "obj", "description gets forwarded for CustomStringConvertible")
        XCTAssert(CombineIdentifier(Empty()).description.starts(with: "CombineIdentifier: 0x"), "classes that are not CustomStringConvertible show their opaque address")
    }
}
