//
//  TestSubject.swift
//  CombineHarvester
//
//  Created by Andreas Hartl on 17.06.19.
//

import Foundation

enum TestError: Error {
    case error
    case otherError
}

class TestSubject<Failure>: Subject where Failure: Error {
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
    typealias Failure = Failure

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

    func send(completion: Subscribers.Completion<Failure>) {
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
