//
//  SubjectTests.swift
//  CombineHarvesterTests
//
//  Created by Andreas Hartl on 14.06.19.
//

import XCTest
@testable import CombineHarvester

class SubjectTests: XCTestCase {
    private enum TestError: Error {
        case error
    }

    private class TestSubject: Subject {
        private class TestSubscription: Subscription {
            let subject: TestSubject

            init(subject: TestSubject) {
                self.subject = subject
            }

            func request(_: Subscribers.Demand) {
            }

            func cancel() {
                self.subject.subscriber = nil
            }
        }

        typealias Output = String

        typealias Failure = TestError

        var values = [Output]()
        var completion = [Subscribers.Completion<Failure>]()
        var subscriber: AnySubscriber<Output, Failure>?

        func send(_ value: Output) {
            guard self.completion.isEmpty else {
                return
            }
            _ = self.subscriber?.receive(value)
            self.values.append(value)
        }

        func send(completion: Subscribers.Completion<SubjectTests.TestSubject.Failure>) {
            guard self.completion.isEmpty else {
                return
            }

            self.subscriber?.receive(completion: completion)
            self.completion.append(completion)
        }

        func receive<S>(subscriber: S) where S: Subscriber, Failure == S.Failure, Output == S.Input {
            self.subscriber = subscriber.eraseToAnySubscriber()
            subscriber.receive(subscription: TestSubscription(subject: self))
        }
    }

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
