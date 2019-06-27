//
//  TransformingSubscriber.swift
//  CombineHarvester
//
//  Created by Andreas Hartl on 24.06.19.
//

import Foundation

class TransformingSubscriber<Input, InputFailure: Error, Output, OutputFailure: Error>: Subscriber, Subscription {
    typealias Failure = InputFailure

    enum TransformationResult {
        case value(Output)
        case demand(Subscribers.Demand)
        case finished
        case failure(OutputFailure)
    }

    enum CancelReason {
        case cancel
        case finished
        case failure
        case `deinit`
    }

    let subscriber: AnySubscriber<Output, OutputFailure>
    let transformRequest: (Subscribers.Demand) -> [TransformationResult]
    let transformValue: (Input) -> [TransformationResult]
    let transformCompletion: (Subscribers.Completion<InputFailure>) -> [TransformationResult]
    let cancelled: ((CancelReason) -> Void)?

    private var upstreamSubscription: Subscription? {
        willSet {
            if self.upstreamSubscription?.combineIdentifier != newValue?.combineIdentifier {
                self.upstreamSubscription?.cancel()
            }
        }
    }

    convenience init<S: Subscriber>(subscriber: S,
                                    transformRequest: @escaping (Subscribers.Demand) -> [TransformationResult],
                                    transformValue: @escaping (Input) -> [TransformationResult],
                                    cancelled: ((CancelReason) -> Void)? = nil) where OutputFailure == Error, OutputFailure == S.Failure, S.Input == Output {
        self.init(subscriber: subscriber,
                  transformRequest: transformRequest,
                  transformValue: transformValue,
                  transformCompletion: { completion in
                      switch completion {
                      case .finished:
                          return [.finished]
                      case let .failure(error):
                          return [.failure(error)]
                      }
        }, cancelled: cancelled)
    }

    convenience init<S: Subscriber>(subscriber: S,
                                    transformRequest: @escaping (Subscribers.Demand) -> [TransformationResult],
                                    transformValue: @escaping (Input) -> [TransformationResult],
                                    cancelled: ((CancelReason) -> Void)? = nil) where OutputFailure == S.Failure, InputFailure == S.Failure, S.Input == Output {
        self.init(subscriber: subscriber,
                  transformRequest: transformRequest,
                  transformValue: transformValue,
                  transformCompletion: { completion in
                      switch completion {
                      case .finished:
                          return [.finished]
                      case let .failure(error):
                          return [.failure(error)]
                      }
        }, cancelled: cancelled)
    }

    init<S: Subscriber>(subscriber: S,
                        transformRequest: @escaping (Subscribers.Demand) -> [TransformationResult],
                        transformValue: @escaping (Input) -> [TransformationResult],
                        transformCompletion: @escaping (Subscribers.Completion<InputFailure>) -> [TransformationResult],
                        cancelled: ((CancelReason) -> Void)? = nil) where OutputFailure == S.Failure, S.Input == Output {
        self.subscriber = subscriber.eraseToAnySubscriber()
        self.transformRequest = transformRequest
        self.transformCompletion = transformCompletion
        self.transformValue = transformValue
        self.cancelled = cancelled
    }

    private func apply(results: [TransformationResult]) -> Subscribers.Demand? {
        var demand = Subscribers.Demand.none
        for transformationResult in results {
            switch transformationResult {
            case let .value(value):
                demand += self.subscriber.receive(value) - 1
            case let .demand(d):
                demand += d
            case .finished:
                defer {
                    self.cancel(reason: .finished)
                }
                self.subscriber.receive(completion: .finished)
                return nil
            case let .failure(error):
                defer {
                    self.cancel(reason: .failure)
                }
                self.subscriber.receive(completion: .failure(error))
                return nil
            }
        }
        return demand > .none ? demand : .none
    }

    func receive(subscription: Subscription) {
        self.upstreamSubscription = subscription
        self.subscriber.receive(subscription: self)
    }

    func receive(_ input: Input) -> Subscribers.Demand {
        return self.apply(results: self.transformValue(input)) ?? .none
    }

    func receive(completion: Subscribers.Completion<InputFailure>) {
        defer {
            switch completion {
            case .finished:
                self.cancel(reason: .finished)
            case .failure:
                self.cancel(reason: .failure)
            }
        }
        _ = self.apply(results: self.transformCompletion(completion))
    }

    func request(_ demand: Subscribers.Demand) {
        guard let upstreamRequest = self.apply(results: self.transformRequest(demand)), upstreamRequest > .none else {
            return
        }
        self.upstreamSubscription?.request(upstreamRequest)
    }

    private func cancel(reason: CancelReason) {
        guard self.upstreamSubscription != nil else {
            return
        }
        self.upstreamSubscription = nil
        self.cancelled?(reason)
    }

    func cancel() {
        self.cancel(reason: .cancel)
    }

    deinit {
        self.cancel(reason: .deinit)
    }
}
