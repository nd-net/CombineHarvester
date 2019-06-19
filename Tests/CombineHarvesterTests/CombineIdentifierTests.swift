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
        XCTAssert(CombineIdentifier().description.starts(with: "CombineIdentifier: 0x"), "Combine identifiers always show memory address for empty inits")

        XCTAssert(CombineIdentifier(Empty()).description.starts(with: "CombineIdentifier: 0x"), "Combine identifiers always show memory address non-empty inits")
    }
}
