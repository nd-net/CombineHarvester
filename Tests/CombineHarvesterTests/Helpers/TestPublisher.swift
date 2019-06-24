//
//  TestPublisher.swift
//  CombineHarvesterTests
//
//  Created by Andreas Hartl on 24.06.19.
//

import XCTest
@testable import CombineHarvester

struct TestPublisher<Failure>: Publisher, Equatable where Failure: Error & Equatable {
    typealias Output = String

    var content: [Result<Output, Failure>]

    init(_ content: [Result<Output, Failure>]) {
        self.content = content
    }

    func receive<S>(subscriber: S) where S: Subscriber, Failure == S.Failure, Output == S.Input {
        let subscription = IteratingSubscription(iterator: content.makeIterator(), subscriber: subscriber)
        subscriber.receive(subscription: subscription)
    }
}
