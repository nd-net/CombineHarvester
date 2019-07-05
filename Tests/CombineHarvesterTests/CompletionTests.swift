//
//  CompletionTests.swift
//  CombineHarvesterTests
//
//  Created by Andreas Hartl on 05.07.19.
//

import XCTest
@testable import CombineHarvester

class CompletionTests: XCTestCase {
    func testEquatable() {
        XCTAssertEqual(Subscribers.Completion<TestError>.finished, Subscribers.Completion<TestError>.finished)
        XCTAssertEqual(Subscribers.Completion<TestError>.failure(.error), Subscribers.Completion<TestError>.failure(.error))
        XCTAssertNotEqual(Subscribers.Completion<TestError>.failure(.error), Subscribers.Completion<TestError>.finished)
    }

    func testCodable() throws {
        func roundtrip<T: Codable>(_ value: T) throws -> T {
            let data = try JSONEncoder().encode(value)
            return try JSONDecoder().decode(T.self, from: data)
        }

        XCTAssertEqual(try roundtrip(Subscribers.Completion<TestError>.finished), Subscribers.Completion<TestError>.finished)
        XCTAssertEqual(try roundtrip(Subscribers.Completion<TestError>.failure(.error)), Subscribers.Completion<TestError>.failure(.error))
    }
}
