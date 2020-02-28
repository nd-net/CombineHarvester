//
//  TestSubject.swift
//  CombineHarvester
//
//  Created by Andreas Hartl on 17.06.19.
//

import Foundation
@testable import CombineHarvester

enum TestError: String, Error, Codable {
    case error
    case otherError
}

class TestSubject<Output, Failure: Error>: Subject {
    private class TestSubscription: Subscription {
        let subject: TestSubject

        init(subject: TestSubject) {
            self.subject = subject
        }

        func request(_: Subscribers.Demand) {
        }

        func cancel() {
            self.subject.cancel()
        }
    }

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

    func receive<S: Subscriber>(subscriber: S) where Failure == S.Failure, Output == S.Input {
        self.subscriber = subscriber.eraseToAnySubscriber()
        let subscription = TestSubscription(subject: self)
        subscriber.receive(subscription: subscription)
    }

    func cancel() {
        self.subscriber = nil
    }
}
