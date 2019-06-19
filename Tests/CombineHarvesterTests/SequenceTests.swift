//
//  SequenceTests.swift
//  CombineHarvesterTests
//
//  Created by Andreas Hartl on 24.06.19.
//

import XCTest
@testable import CombineHarvester

class SequenceTests: XCTestCase {
    typealias PublishersSequence = Publishers.Sequence<[String], Never>
    // swiftformat:disable:next typeSugar
    typealias PublishersOptional = Publishers.Optional

    func testSubscribe() {
        var subject = TestSubject<String, Never>()
        var publisher = PublishersSequence(sequence: ["Hello"])
        _ = publisher.subscribe(subject)

        XCTAssertEqual(subject.values, ["Hello"])
        XCTAssertEqual(subject.completion, [.finished])

        subject = TestSubject()
        publisher = PublishersSequence(sequence: [])
        _ = publisher.subscribe(subject)

        XCTAssertEqual(subject.values, [])
        XCTAssertEqual(subject.completion, [.finished])

        subject = TestSubject()
        publisher = PublishersSequence(sequence: ["Hello", "World"])
        _ = publisher.subscribe(subject)

        XCTAssertEqual(subject.values, ["Hello", "World"])
        XCTAssertEqual(subject.completion, [.finished])
    }

    func testEquals() {
        XCTAssertEqual(PublishersSequence(sequence: ["Hello"]), PublishersSequence(sequence: ["Hello"]))
        XCTAssertEqual(PublishersSequence(sequence: []), PublishersSequence(sequence: []))
    }

    func testAllSatisfy() {
        XCTAssertEqual(PublishersSequence(sequence: []).allSatisfy { $0 == "Hello" }, Publishers.Once(true))
        XCTAssertEqual(PublishersSequence(sequence: ["Hello"]).allSatisfy { $0 == "Hello" }, Publishers.Once(true))
        XCTAssertEqual(PublishersSequence(sequence: ["Hello", "Hello"]).allSatisfy { $0 == "Hello" }, Publishers.Once(true))
        XCTAssertEqual(PublishersSequence(sequence: ["Hello", "World"]).allSatisfy { $0 == "Hello" }, Publishers.Once(false))

        XCTAssertEqual(
            PublishersSequence(sequence: [])
                .tryAllSatisfy { $0 == "Hello" }
                .mapError { $0 as! TestError },
            Publishers.Once(true)
        )
        XCTAssertEqual(
            PublishersSequence(sequence: ["Hello"])
                .tryAllSatisfy { $0 == "Hello" }
                .mapError { $0 as! TestError },
            Publishers.Once(true)
        )
        XCTAssertEqual(
            PublishersSequence(sequence: ["Hello", "Hello"])
                .tryAllSatisfy { $0 == "Hello" }
                .mapError { $0 as! TestError },
            Publishers.Once(true)
        )
        XCTAssertEqual(
            PublishersSequence(sequence: ["Hello", "World"])
                .tryAllSatisfy { $0 == "Hello" }
                .mapError { $0 as! TestError },
            Publishers.Once(false)
        )
        XCTAssertEqual(
            PublishersSequence(sequence: [])
                .tryAllSatisfy { _ in throw TestError.error }
                .mapError { $0 as! TestError },
            Publishers.Once(true)
        )
        XCTAssertEqual(
            PublishersSequence(sequence: ["Hello", "World"])
                .tryAllSatisfy { _ in throw TestError.error }
                .mapError { $0 as! TestError },
            Publishers.Once(.failure(TestError.error))
        )
    }

    func testCollect() {
        XCTAssertEqual(PublishersSequence(sequence: []).collect(), Publishers.Once([]))
        XCTAssertEqual(PublishersSequence(sequence: ["Hello"]).collect(), Publishers.Once(["Hello"]))
    }

    func testCompactMap() {
        XCTAssertEqual(PublishersSequence(sequence: []).compactMap { $0 }, PublishersSequence(sequence: []))
        XCTAssertEqual(PublishersSequence(sequence: ["Hello"]).compactMap { $0 }, PublishersSequence(sequence: ["Hello"]))
        XCTAssertEqual(PublishersSequence(sequence: ["Hello", "World"]).compactMap { _ -> String? in nil }, PublishersSequence(sequence: []))
        XCTAssertEqual(PublishersSequence(sequence: ["Hello", "World"]).compactMap { $0 == "Hello" ? $0 : nil }, PublishersSequence(sequence: ["Hello"]))
    }

    func testMin() {
        XCTAssertEqual(PublishersSequence(sequence: []).min(), PublishersOptional(nil))
        XCTAssertEqual(PublishersSequence(sequence: ["Hello"]).min(), PublishersOptional("Hello"))
        XCTAssertEqual(PublishersSequence(sequence: ["Hello", "World"]).min(), PublishersOptional("Hello"))
        XCTAssertEqual(PublishersSequence(sequence: []).min(by: { $0 > $1 }), PublishersOptional(nil))
        XCTAssertEqual(PublishersSequence(sequence: ["Hello"]).min(by: { $0 > $1 }), PublishersOptional("Hello"))
        XCTAssertEqual(PublishersSequence(sequence: ["Hello", "World"]).min(by: { $0 > $1 }), PublishersOptional("World"))

        XCTAssertEqual(
            PublishersSequence(sequence: [])
                .tryMin(by: { $0 > $1 })
                .mapError { $0 as! TestError },
            PublishersOptional(nil)
        )
        XCTAssertEqual(
            PublishersSequence(sequence: ["Hello"])
                .tryMin(by: { $0 > $1 })
                .mapError { $0 as! TestError },
            PublishersOptional("Hello")
        )
        XCTAssertEqual(
            PublishersSequence(sequence: ["Hello", "World"])
                .tryMin(by: { $0 > $1 })
                .mapError { $0 as! TestError },
            PublishersOptional("World")
        )
        XCTAssertEqual(
            PublishersSequence(sequence: [])
                .tryMin(by: { _, _ in throw TestError.error })
                .mapError { $0 as! TestError },
            PublishersOptional(nil)
        )
        XCTAssertEqual(
            PublishersSequence(sequence: ["Hello"])
                .tryMin(by: { _, _ in throw TestError.error })
                .mapError { $0 as! TestError },
            PublishersOptional("Hello")
        )
        XCTAssertEqual(
            PublishersSequence(sequence: ["Hello", "World"])
                .tryMin(by: { _, _ in throw TestError.error })
                .mapError { $0 as! TestError },
            PublishersOptional(.failure(TestError.error))
        )
    }

    func testMax() {
        XCTAssertEqual(PublishersSequence(sequence: []).max(), PublishersOptional(nil))
        XCTAssertEqual(PublishersSequence(sequence: ["Hello"]).max(), PublishersOptional("Hello"))
        XCTAssertEqual(PublishersSequence(sequence: ["Hello", "World"]).max(), PublishersOptional("World"))
        XCTAssertEqual(PublishersSequence(sequence: []).max(by: { $0 > $1 }), PublishersOptional(nil))
        XCTAssertEqual(PublishersSequence(sequence: ["Hello"]).max(by: { $0 > $1 }), PublishersOptional("Hello"))
        XCTAssertEqual(PublishersSequence(sequence: ["Hello", "World"]).max(by: { $0 > $1 }), PublishersOptional("Hello"))

        XCTAssertEqual(
            PublishersSequence(sequence: [])
                .tryMax(by: { $0 > $1 })
                .mapError { $0 as! TestError },
            PublishersOptional(nil)
        )
        XCTAssertEqual(
            PublishersSequence(sequence: ["Hello"])
                .tryMax(by: { $0 > $1 })
                .mapError { $0 as! TestError },
            PublishersOptional("Hello")
        )
        XCTAssertEqual(
            PublishersSequence(sequence: ["Hello", "World"])
                .tryMax(by: { $0 > $1 })
                .mapError { $0 as! TestError },
            PublishersOptional("Hello")
        )
        XCTAssertEqual(
            PublishersSequence(sequence: [])
                .tryMax(by: { _, _ in throw TestError.error })
                .mapError { $0 as! TestError },
            PublishersOptional(nil)
        )
        XCTAssertEqual(
            PublishersSequence(sequence: ["Hello"])
                .tryMax(by: { _, _ in throw TestError.error })
                .mapError { $0 as! TestError },
            PublishersOptional("Hello")
        )
        XCTAssertEqual(
            PublishersSequence(sequence: ["Hello", "World"])
                .tryMax(by: { _, _ in throw TestError.error })
                .mapError { $0 as! TestError },
            PublishersOptional(.failure(TestError.error))
        )
    }

    func testContains() {
        XCTAssertEqual(PublishersSequence(sequence: []).contains("Hello"), Publishers.Once(false))
        XCTAssertEqual(PublishersSequence(sequence: ["Hello"]).contains("Hello"), Publishers.Once(true))
        XCTAssertEqual(PublishersSequence(sequence: ["Hello"]).contains("Hi"), Publishers.Once(false))
        XCTAssertEqual(PublishersSequence(sequence: ["Hello", "Hi"]).contains("Hi"), Publishers.Once(true))

        XCTAssertEqual(PublishersSequence(sequence: []).contains(where: { $0 == "Hello" }), Publishers.Once(false))
        XCTAssertEqual(PublishersSequence(sequence: ["Hello"]).contains(where: { $0 == "Hello" }), Publishers.Once(true))
        XCTAssertEqual(PublishersSequence(sequence: ["Hello"]).contains(where: { $0 == "Hi" }), Publishers.Once(false))
        XCTAssertEqual(PublishersSequence(sequence: ["Hello", "Hi"]).contains(where: { $0 == "Hi" }), Publishers.Once(true))

        XCTAssertEqual(
            PublishersSequence(sequence: [])
                .tryContains(where: { $0 == "Hello" })
                .mapError { $0 as! TestError },
            Publishers.Once(false)
        )
        XCTAssertEqual(
            PublishersSequence(sequence: ["Hello"])
                .tryContains(where: { $0 == "Hello" })
                .mapError { $0 as! TestError },
            Publishers.Once(true)
        )
        XCTAssertEqual(
            PublishersSequence(sequence: ["Hello"])
                .tryContains(where: { $0 == "Hi" })
                .mapError { $0 as! TestError },
            Publishers.Once(false)
        )
        XCTAssertEqual(
            PublishersSequence(sequence: ["Hello", "Hi"])
                .tryContains(where: { $0 == "Hi" })
                .mapError { $0 as! TestError },
            Publishers.Once(true)
        )
        XCTAssertEqual(
            PublishersSequence(sequence: [])
                .tryContains(where: { _ in throw TestError.error })
                .mapError { $0 as! TestError },
            Publishers.Once(false)
        )
        XCTAssertEqual(
            PublishersSequence(sequence: ["Hello"])
                .tryContains(where: { _ in throw TestError.error })
                .mapError { $0 as! TestError },
            Publishers.Once(.failure(TestError.error))
        )
    }

    func testCount() {
        XCTAssertEqual(Publishers.Sequence<String, Never>(sequence: "").count(), Publishers.Once<Int, Never>(0))
        XCTAssertEqual(Publishers.Sequence<String, Never>(sequence: "H").count(), Publishers.Once<Int, Never>(1))

        XCTAssertEqual(PublishersSequence(sequence: []).count(), Publishers.Optional(0), "RandomAccessCollection")
        XCTAssertEqual(PublishersSequence(sequence: ["Hello"]).count(), Publishers.Optional(1), "RandomAccessCollection")
    }

    func testDrop() {
        for sequence in [[], ["Hello"], ["Hello", "World"]] {
            let subject = TestSubject<String, Never>()
            let publisher = PublishersSequence(sequence: sequence).dropFirst()
            _ = publisher.subscribe(subject)

            XCTAssertEqual(subject.values, Array(sequence.dropFirst()))
            XCTAssertEqual(subject.completion, [.finished])
        }

        for sequence in [[], ["Hello"], ["Hello", "World"]] {
            let subject = TestSubject<String, Never>()
            let publisher = PublishersSequence(sequence: sequence).dropFirst(2)
            _ = publisher.subscribe(subject)

            XCTAssertEqual(subject.values, Array(sequence.dropFirst(2)))
            XCTAssertEqual(subject.completion, [.finished])
        }
        for sequence in [[], ["Hello"], ["Hello", "World"]] {
            let subject = TestSubject<String, Never>()
            let publisher = PublishersSequence(sequence: sequence).drop(while: { $0 == "Hello" })
            _ = publisher.subscribe(subject)

            XCTAssertEqual(subject.values, sequence.count == 2 ? ["World"] : [])
            XCTAssertEqual(subject.completion, [.finished])
        }
    }

    func testFirst() {
        XCTAssertEqual(PublishersSequence(sequence: []).first(), Publishers.Optional(nil))
        XCTAssertEqual(PublishersSequence(sequence: ["Hello"]).first(), Publishers.Optional("Hello"))
        XCTAssertEqual(PublishersSequence(sequence: ["Hello", "World"]).first(), Publishers.Optional("Hello"))

        XCTAssertEqual(PublishersSequence(sequence: []).first { $0 == "Hello" }, Publishers.Optional(nil))
        XCTAssertEqual(PublishersSequence(sequence: ["Hello"]).first { $0 == "Hello" }, Publishers.Optional("Hello"))
        XCTAssertEqual(PublishersSequence(sequence: ["Hello"]).first { _ in false }, Publishers.Optional(nil))
        XCTAssertEqual(PublishersSequence(sequence: ["Hello", "World"]).first { $0 == "Hello" }, Publishers.Optional("Hello"))
        XCTAssertEqual(PublishersSequence(sequence: ["Hello", "World"]).first { $0 == "World" }, Publishers.Optional("World"))
        XCTAssertEqual(PublishersSequence(sequence: ["Hello"]).first { _ in false }, Publishers.Optional(nil))

        XCTAssertEqual(
            PublishersSequence(sequence: [])
                .tryFirst { $0 == "Hello" }
                .mapError { $0 as! TestError },
            Publishers.Optional(nil)
        )
        XCTAssertEqual(
            PublishersSequence(sequence: ["Hello"])
                .tryFirst { $0 == "Hello" }
                .mapError { $0 as! TestError },
            Publishers.Optional("Hello")
        )
        XCTAssertEqual(
            PublishersSequence(sequence: ["Hello"])
                .tryFirst { _ in false }
                .mapError { $0 as! TestError },
            Publishers.Optional(nil)
        )
        XCTAssertEqual(
            PublishersSequence(sequence: ["Hello", "World"])
                .tryFirst { $0 == "Hello" }
                .mapError { $0 as! TestError },
            Publishers.Optional("Hello")
        )
        XCTAssertEqual(
            PublishersSequence(sequence: ["Hello", "World"])
                .tryFirst { $0 == "World" }
                .mapError { $0 as! TestError },
            Publishers.Optional("World")
        )
        XCTAssertEqual(
            PublishersSequence(sequence: ["Hello"])
                .tryFirst { _ in false }
                .mapError { $0 as! TestError },
            Publishers.Optional(nil)
        )
        XCTAssertEqual(
            PublishersSequence(sequence: [])
                .tryFirst { _ in throw TestError.error }
                .mapError { $0 as! TestError },
            Publishers.Optional(nil)
        )
        XCTAssertEqual(
            PublishersSequence(sequence: ["Hello"])
                .tryFirst { _ in throw TestError.error }
                .mapError { $0 as! TestError },
            Publishers.Optional(TestError.error)
        )
    }

    func testLast() {
        XCTAssertEqual(PublishersSequence(sequence: []).last(), Publishers.Optional(nil))
        XCTAssertEqual(PublishersSequence(sequence: ["Hello"]).last(), Publishers.Optional("Hello"))
        XCTAssertEqual(PublishersSequence(sequence: ["Hello", "World"]).last(), Publishers.Optional("World"))

        XCTAssertEqual(PublishersSequence(sequence: []).last { $0 == "Hello" }, Publishers.Optional(nil))
        XCTAssertEqual(PublishersSequence(sequence: ["Hello"]).last { $0 == "Hello" }, Publishers.Optional("Hello"))
        XCTAssertEqual(PublishersSequence(sequence: ["Hello"]).last { _ in false }, Publishers.Optional(nil))
        XCTAssertEqual(PublishersSequence(sequence: ["Hello", "World"]).last { $0 == "Hello" }, Publishers.Optional("Hello"))
        XCTAssertEqual(PublishersSequence(sequence: ["Hello", "World"]).last { $0 == "World" }, Publishers.Optional("World"))
        XCTAssertEqual(PublishersSequence(sequence: ["Hello"]).last { _ in false }, Publishers.Optional(nil))

        XCTAssertEqual(
            PublishersSequence(sequence: [])
                .tryLast { $0 == "Hello" }
                .mapError { $0 as! TestError },
            Publishers.Optional(nil)
        )
        XCTAssertEqual(
            PublishersSequence(sequence: ["Hello"])
                .tryLast { $0 == "Hello" }
                .mapError { $0 as! TestError },
            Publishers.Optional("Hello")
        )
        XCTAssertEqual(
            PublishersSequence(sequence: ["Hello"])
                .tryLast { _ in false }
                .mapError { $0 as! TestError },
            Publishers.Optional(nil)
        )
        XCTAssertEqual(
            PublishersSequence(sequence: ["Hello", "World"])
                .tryLast { $0 == "Hello" }
                .mapError { $0 as! TestError },
            Publishers.Optional("Hello")
        )
        XCTAssertEqual(
            PublishersSequence(sequence: ["Hello", "World"])
                .tryLast { $0 == "World" }
                .mapError { $0 as! TestError },
            Publishers.Optional("World")
        )
        XCTAssertEqual(
            PublishersSequence(sequence: ["Hello"])
                .tryLast { _ in false }
                .mapError { $0 as! TestError },
            Publishers.Optional(nil)
        )
        XCTAssertEqual(
            PublishersSequence(sequence: [])
                .tryLast { _ in throw TestError.error }
                .mapError { $0 as! TestError },
            Publishers.Optional(nil)
        )
        XCTAssertEqual(
            PublishersSequence(sequence: ["Hello"])
                .tryLast { _ in throw TestError.error }
                .mapError { $0 as! TestError },
            Publishers.Optional(TestError.error)
        )
    }

    func testFilter() {
        XCTAssertEqual(PublishersSequence(sequence: []).filter { $0 == "Hello" }, PublishersSequence(sequence: []))
        XCTAssertEqual(PublishersSequence(sequence: ["Hello"]).filter { $0 == "Hello" }, PublishersSequence(sequence: ["Hello"]))
        XCTAssertEqual(PublishersSequence(sequence: ["Hello"]).filter { $0 != "Hello" }, PublishersSequence(sequence: []))
        XCTAssertEqual(PublishersSequence(sequence: ["Hello", "World"]).filter { $0 != "Hello" }, PublishersSequence(sequence: ["World"]))
    }

    func testIgnoreOutput() {
        XCTAssertEqual(PublishersSequence(sequence: []).ignoreOutput(), Publishers.Empty())
        XCTAssertEqual(PublishersSequence(sequence: ["Hello"]).ignoreOutput(), Publishers.Empty())
    }

    func testMap() {
        XCTAssertEqual(PublishersSequence(sequence: []).map { "!\($0)!" }, PublishersSequence(sequence: []))
        XCTAssertEqual(PublishersSequence(sequence: ["Hello"]).map { "!\($0)!" }, PublishersSequence(sequence: ["!Hello!"]))
    }

    func testOutput() {
        XCTAssertEqual(PublishersSequence(sequence: []).output(at: 0), PublishersOptional(nil))
        XCTAssertEqual(PublishersSequence(sequence: ["Hello"]).output(at: 0), PublishersOptional("Hello"))
        XCTAssertEqual(PublishersSequence(sequence: ["Hello"]).output(at: 1), PublishersOptional(nil))

        XCTAssertEqual(PublishersSequence(sequence: []).output(in: 0..<1), Publishers.Sequence(sequence: []))
        XCTAssertEqual(PublishersSequence(sequence: ["Hello"]).output(in: 0..<1), Publishers.Sequence(sequence: ["Hello"]))
        XCTAssertEqual(PublishersSequence(sequence: ["Hello"]).output(in: 1..<1), Publishers.Sequence(sequence: []))

        XCTAssertEqual(Publishers.Sequence<String, Never>(sequence: "").output(at: "".startIndex), PublishersOptional(nil))
        XCTAssertEqual(Publishers.Sequence<String, Never>(sequence: "Hello").output(at: "".endIndex), PublishersOptional("H"))
        XCTAssertEqual(Publishers.Sequence<String, Never>(sequence: "Hello").output(at: "Hello".endIndex), PublishersOptional(nil))

        XCTAssertEqual(Publishers.Sequence<String, Never>(sequence: "").output(in: "".startIndex..<"".endIndex), Publishers.Sequence<[Character], Never>(sequence: []))
        XCTAssertEqual(Publishers.Sequence<String, Never>(sequence: "Hello").output(in: "".startIndex..<"H".endIndex), Publishers.Sequence<[Character], Never>(sequence: ["H"]))
        XCTAssertEqual(Publishers.Sequence<String, Never>(sequence: "Hello").output(in: "".startIndex..<"Hello".endIndex), Publishers.Sequence<[Character], Never>(sequence: ["H", "e", "l", "l", "o"]))
    }

    func testPrefix() {
        for sequence in [[], ["Hello"], ["Hello", "World"]] {
            let subject = TestSubject<String, Never>()
            let publisher = PublishersSequence(sequence: sequence).prefix(1)
            _ = publisher.subscribe(subject)

            XCTAssertEqual(subject.values, Array(sequence.prefix(1)))
            XCTAssertEqual(subject.completion, [.finished])
        }

        for sequence in [[], ["Hello"], ["Hello", "World"]] {
            let subject = TestSubject<String, Never>()
            let publisher = PublishersSequence(sequence: sequence).prefix(while: { $0 == "Hello" })
            _ = publisher.subscribe(subject)

            XCTAssertEqual(subject.values, sequence.count == 2 ? ["Hello"] : sequence)
            XCTAssertEqual(subject.completion, [.finished])
        }
    }

    func testPrepend() {
        XCTAssertEqual(PublishersSequence(sequence: []).prepend(), PublishersSequence(sequence: []))
        XCTAssertEqual(PublishersSequence(sequence: []).prepend("Hello"), PublishersSequence(sequence: ["Hello"]))
        XCTAssertEqual(PublishersSequence(sequence: ["Hello"]).prepend("World"), PublishersSequence(sequence: ["World", "Hello"]))
        XCTAssertEqual(PublishersSequence(sequence: []).prepend(["World"]), PublishersSequence(sequence: ["World"]))
        XCTAssertEqual(PublishersSequence(sequence: ["Hello"]).prepend(["World"]), PublishersSequence(sequence: ["World", "Hello"]))
        XCTAssertEqual(PublishersSequence(sequence: []).prepend(PublishersSequence(sequence: [])), PublishersSequence(sequence: []))
        XCTAssertEqual(PublishersSequence(sequence: []).prepend(PublishersSequence(sequence: ["Hello"])), PublishersSequence(sequence: ["Hello"]))
        XCTAssertEqual(PublishersSequence(sequence: ["Hello"]).prepend(PublishersSequence(sequence: ["World"])), PublishersSequence(sequence: ["World", "Hello"]))
    }

    func testAppend() {
        XCTAssertEqual(PublishersSequence(sequence: []).append(), PublishersSequence(sequence: []))
        XCTAssertEqual(PublishersSequence(sequence: []).append("Hello"), PublishersSequence(sequence: ["Hello"]))
        XCTAssertEqual(PublishersSequence(sequence: ["Hello"]).append("World"), PublishersSequence(sequence: ["Hello", "World"]))
        XCTAssertEqual(PublishersSequence(sequence: []).append(["World"]), PublishersSequence(sequence: ["World"]))
        XCTAssertEqual(PublishersSequence(sequence: ["Hello"]).append(["World"]), PublishersSequence(sequence: ["Hello", "World"]))
        XCTAssertEqual(PublishersSequence(sequence: []).append(PublishersSequence(sequence: [])), PublishersSequence(sequence: []))
        XCTAssertEqual(PublishersSequence(sequence: []).append(PublishersSequence(sequence: ["Hello"])), PublishersSequence(sequence: ["Hello"]))
        XCTAssertEqual(PublishersSequence(sequence: ["Hello"]).append(PublishersSequence(sequence: ["World"])), PublishersSequence(sequence: ["Hello", "World"]))
    }

    func testReduce() {
        XCTAssertEqual(PublishersSequence(sequence: []).reduce(0) { $0 + $1.count }, Publishers.Once(0))
        XCTAssertEqual(PublishersSequence(sequence: ["Hello"]).reduce(0) { $0 + $1.count }, Publishers.Once(5))
        XCTAssertEqual(PublishersSequence(sequence: ["Hello", "World"]).reduce(0) { $0 + $1.count }, Publishers.Once(10))

        XCTAssertEqual(
            PublishersSequence(sequence: [])
                .tryReduce(0) { $0 + $1.count }
                .mapError { $0 as! TestError },
            Publishers.Once(0)
        )
        XCTAssertEqual(
            PublishersSequence(sequence: [])
                .tryReduce(0) { _, _ in throw TestError.error }
                .mapError { $0 as! TestError },
            Publishers.Once(0)
        )
        XCTAssertEqual(
            PublishersSequence(sequence: ["Hello"])
                .tryReduce(0) { $0 + $1.count }
                .mapError { $0 as! TestError },
            Publishers.Once(5)
        )
        XCTAssertEqual(
            PublishersSequence(sequence: ["Hello"])
                .tryReduce(0) { _, _ in throw TestError.error }
                .mapError { $0 as! TestError },
            Publishers.Once(.failure(.error))
        )
        XCTAssertEqual(
            PublishersSequence(sequence: ["Hello", "World"])
                .tryReduce(0) { $0 + $1.count }
                .mapError { $0 as! TestError },
            Publishers.Once(10)
        )
        XCTAssertEqual(
            PublishersSequence(sequence: ["Hello", "World"])
                .tryReduce(0) { _, _ in throw TestError.error }
                .mapError { $0 as! TestError },
            Publishers.Once(.failure(.error))
        )
    }

    func testRemoveDuplicates() {
        XCTAssertEqual(PublishersSequence(sequence: []).removeDuplicates(), PublishersSequence(sequence: []))
        XCTAssertEqual(PublishersSequence(sequence: ["Hello"]).removeDuplicates(), PublishersSequence(sequence: ["Hello"]))
        XCTAssertEqual(PublishersSequence(sequence: ["Hello", "Hello"]).removeDuplicates(), PublishersSequence(sequence: ["Hello"]))
        XCTAssertEqual(PublishersSequence(sequence: ["Hello", "Hello", "Hello"]).removeDuplicates(), PublishersSequence(sequence: ["Hello"]))
        XCTAssertEqual(PublishersSequence(sequence: ["Hello", "World", "Hello"]).removeDuplicates(), PublishersSequence(sequence: ["Hello", "World", "Hello"]), "Only duplicates directly next to each other are used")
        XCTAssertEqual(PublishersSequence(sequence: ["Hello", "World", "Hello", "Hello", "Hello"]).removeDuplicates(), PublishersSequence(sequence: ["Hello", "World", "Hello"]), "Only duplicates directly next to each other are used")
    }

    func testReplaceNil() {
        XCTAssertEqual(Publishers.Sequence<[String?], Never>(sequence: []).replaceNil(with: "World"), PublishersSequence(sequence: []))
        XCTAssertEqual(Publishers.Sequence<[String?], Never>(sequence: ["Hello"]).replaceNil(with: "World"), PublishersSequence(sequence: ["Hello"]))
        XCTAssertEqual(Publishers.Sequence<[String?], Never>(sequence: ["Hello", nil]).replaceNil(with: "World"), PublishersSequence(sequence: ["Hello", "World"]))
    }

    func testScan() {
        XCTAssertEqual(PublishersSequence(sequence: []).scan(0) { $0 + $1.count }, Publishers.Sequence<[Int], Never>(sequence: []))
        XCTAssertEqual(PublishersSequence(sequence: ["Hello"]).scan(0) { $0 + $1.count }, Publishers.Sequence<[Int], Never>(sequence: ["Hello".count]))
        XCTAssertEqual(PublishersSequence(sequence: ["Hello", "World"]).scan(0) { $0 + $1.count }, Publishers.Sequence<[Int], Never>(sequence: ["Hello".count, "HelloWorld".count]))
    }

    func testSetFailureType() {
        XCTAssertEqual(PublishersSequence(sequence: []).setFailureType(to: TestError.self), Publishers.Sequence<[String], TestError>(sequence: []))
    }
}
