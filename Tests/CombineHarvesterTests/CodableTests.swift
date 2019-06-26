//
//  CodableTests.swift
//  CombineHarvesterTests
//
//  Created by Andreas Hartl on 26.06.19.
//

import XCTest

class CodableTests: XCTestCase {
    private struct Container: Codable, Equatable {
        var foo: String
    }

    func testDecode() {
        var publisher: TestPublisher<Data, TestError>
        var receiver: TestSubject<Container, TestError>

        publisher = TestPublisher.success([])
        receiver = TestSubject()

        _ = publisher.decode(type: Container.self, decoder: JSONDecoder())
            .mapError { _ in TestError.error }
            .subscribe(receiver)

        XCTAssertEqual(receiver.values, [])
        XCTAssertEqual(receiver.completion, [.finished])

        publisher = TestPublisher([
            """
            {
                "foo": "bar"
            }
            """,
        ].map {
            Result.success($0.data(using: .utf8)!)
        })
        receiver = TestSubject()

        _ = publisher.decode(type: Container.self, decoder: JSONDecoder())
            .mapError { _ in TestError.error }
            .subscribe(receiver)

        XCTAssertEqual(receiver.values, [Container(foo: "bar")])
        XCTAssertEqual(receiver.completion, [.finished])

        publisher = TestPublisher([
            """
            {
                "foo": "bar"
            }
            """, """
            {
                "foo": "baz"
            }
            """,
        ].map {
            Result.success($0.data(using: .utf8)!)
        })
        receiver = TestSubject()

        _ = publisher.decode(type: Container.self, decoder: JSONDecoder())
            .mapError { _ in TestError.error }
            .subscribe(receiver)

        XCTAssertEqual(receiver.values, [Container(foo: "bar"), Container(foo: "baz")])
        XCTAssertEqual(receiver.completion, [.finished])

        publisher = TestPublisher([
            """
            {
                "foo": "bar"
            }
            """, """
            {
                "foo": 1
            }
            """,
        ].map {
            Result.success($0.data(using: .utf8)!)
        })
        receiver = TestSubject()

        _ = publisher.decode(type: Container.self, decoder: JSONDecoder())
            .mapError { _ in TestError.error }
            .subscribe(receiver)

        XCTAssertEqual(receiver.values, [Container(foo: "bar")])
        XCTAssertEqual(receiver.completion, [.failure(.error)])
    }

    func testEncode() {
        var publisher: TestPublisher<Container, TestError>
        var receiver: TestSubject<Data, TestError>

        publisher = TestPublisher.success([])
        receiver = TestSubject()

        _ = publisher.encode(encoder: JSONEncoder())
            .mapError { _ in TestError.error }
            .subscribe(receiver)

        XCTAssertEqual(receiver.values, [])
        XCTAssertEqual(receiver.completion, [.finished])

        publisher = TestPublisher.success([Container(foo: "bar")])
        receiver = TestSubject()

        _ = publisher.encode(encoder: JSONEncoder())
            .mapError { _ in TestError.error }
            .subscribe(receiver)

        XCTAssertEqual(receiver.values, ["{\"foo\":\"bar\"}"].map { $0.data(using: .utf8)! })
        XCTAssertEqual(receiver.completion, [.finished])

        publisher = TestPublisher.success([Container(foo: "bar"), Container(foo: "baz")])
        receiver = TestSubject()

        _ = publisher.encode(encoder: JSONEncoder())
            .mapError { _ in TestError.error }
            .subscribe(receiver)

        XCTAssertEqual(receiver.values, ["{\"foo\":\"bar\"}", "{\"foo\":\"baz\"}"].map { $0.data(using: .utf8)! })
        XCTAssertEqual(receiver.completion, [.finished])
    }
}
