//
//  TestSubscriber.swift
//  CombineHarvester
//
//  Created by Andreas Hartl on 19.06.19.
//

import CombineHarvester
import Foundation

class TestSubscriber<Input, Failure: Error>: Subscriber {
    var subscriptions = [Subscription]()
    var values = [Input]()
    var completions = [Subscribers.Completion<Failure>]()
    var receiveResult = Subscribers.Demand.max(1)

    func receive(subscription: Subscription) {
        self.subscriptions.append(subscription)
        subscription.request(self.receiveResult)
    }

    func receive(_ input: Input) -> Subscribers.Demand {
        self.values.append(input)
        return self.receiveResult
    }

    func receive(completion: Subscribers.Completion<Failure>) {
        self.completions.append(completion)
    }
}
