//
//  RemoveDuplicatesTests.swift
//  CombineHarvesterTests
//
//  Created by Andreas Hartl on 26.06.19.
//

import XCTest

class RemoveDuplicatesTests: XCTestCase {
    private static func removeDuplicates<T>(_ values: [T], predicate: (T, T) -> Bool) -> [T] {
        guard values.count > 1 else {
            return values
        }
        var result = [values[0]]
        for item in values[1...] {
            if !predicate(result.last!, item) {
                result.append(item)
            }
        }
        return result
    }

    struct Case: CustomStringConvertible {
        let testcase: [String]
        let expected: [String]
        let description: String

        init(_ items: [String], predicate: (String, String) -> Bool, description: String) {
            self.init(items, expected: removeDuplicates(items, predicate: predicate), description: description)
        }

        init(_ items: [String], expected: [String], description: String) {
            self.testcase = items
            self.expected = expected
            self.description = description
        }
    }

    func testRemoveDuplicates() {
        for test in [
            Case([], predicate: ==, description: "Empty results"),
            Case(["Hello"], predicate: ==, description: "Single item"),
            Case(["Hello", "Hello"], predicate: ==, description: "Duplicate items"),
            Case(["Hello", "Hello", "Hello"], predicate: ==, description: "Triplicate items"),
            Case(["Hello", "World", "Hello"], predicate: ==, description: "Only duplicates directly next to each other are used"),
            Case(["Hello", "World", "Hello", "Hello", "Hello"], predicate: ==, description: "Only duplicates directly next to each other are used"),
        ] {
            var publisher: TestPublisher<String, TestError>
            var receiver: TestSubject<String, TestError>

            publisher = TestPublisher.success(test.testcase)
            receiver = TestSubject()

            _ = publisher.removeDuplicates()
                .subscribe(receiver)

            XCTAssertEqual(receiver.values, test.expected, test.description)
            XCTAssertEqual(receiver.completion, [.finished])

            publisher = TestPublisher(test.testcase.map(Result.success) + [.failure(.error)])
            receiver = TestSubject()

            _ = publisher.removeDuplicates()
                .subscribe(receiver)

            XCTAssertEqual(receiver.values, test.expected, test.description)
            XCTAssertEqual(receiver.completion, [.failure(.error)])
        }
    }

    func testRemoveDuplicatesBy() {
        for test in [
            Case([], predicate: { $0.count == $1.count }, description: "Empty results"),
            Case(["Hello"], predicate: { $0.count == $1.count }, description: "Single item"),
            Case(["Hello", "Hello"], predicate: { $0.count == $1.count }, description: "Duplicate items"),
            Case(["Hello", "Hello", "Hello"], predicate: { $0.count == $1.count }, description: "Triplicate items"),
            Case(["Hello", "World", "Hello"], predicate: { $0.count == $1.count }, description: "Multiple items with same length"),
            Case(["Hello", "Worlder", "Hello", "Hello", "Hello"], predicate: { $0.count == $1.count }, description: "Only duplicates directly next to each other are used"),
        ] {
            var publisher: TestPublisher<String, TestError>
            var receiver: TestSubject<String, TestError>

            publisher = TestPublisher.success(test.testcase)
            receiver = TestSubject()

            _ = publisher.removeDuplicates(by: { $0.count == $1.count })
                .subscribe(receiver)

            XCTAssertEqual(receiver.values, test.expected, test.description)
            XCTAssertEqual(receiver.completion, [.finished])
        }
    }

    func testTryRemoveDuplicates() {
        for test in [
            Case([], predicate: ==, description: "Empty results"),
            Case(["Hello"], predicate: ==, description: "Single item"),
            Case(["Hello", "Hello"], predicate: ==, description: "Duplicate items"),
            Case(["Hello", "World", "Hello"], expected: ["Hello"], description: "Error"),
            Case(["Hello", "World", "Hello", "Hello", "Hello"], expected: ["Hello"], description: "Error with data after"),
        ] {
            var publisher: TestPublisher<String, TestError>
            var receiver: TestSubject<String, TestError>

            publisher = TestPublisher.success(test.testcase)
            receiver = TestSubject()

            _ = publisher.tryRemoveDuplicates(by: {
                if $0 == "World" || $1 == "World" {
                    throw TestError.otherError
                }
                return $0.count == $1.count
            })
                .mapError { $0 as! TestError }
                .subscribe(receiver)

            XCTAssertEqual(receiver.values, test.expected, test.description)
            XCTAssertEqual(receiver.completion, test.description.contains("Error") ? [.failure(.otherError)] : [.finished], test.description)
        }
    }
}
