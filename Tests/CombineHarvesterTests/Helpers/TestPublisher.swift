//
//  TestPublisher.swift
//  CombineHarvesterTests
//
//  Created by Andreas Hartl on 24.06.19.
//

import XCTest
@testable import CombineHarvester

struct TestPublisher<Output, Failure>: Publisher, Equatable where Output: Equatable, Failure: Error & Equatable {
    var content: [Result<Output, Failure>]

    static func success(_ content: [Output]) -> TestPublisher {
        return TestPublisher(content.map(Result.success))
    }

    init(_ content: Result<Output, Failure>...) {
        self.content = content
    }

    init(_ content: [Result<Output, Failure>]) {
        self.content = content
    }

    func receive<S: Subscriber>(subscriber: S) where Failure == S.Failure, Output == S.Input {
        let subscription = IteratingSubscription(iterator: content.makeIterator(), subscriber: subscriber)
        subscriber.receive(subscription: subscription)
    }
}
