
extension Publishers {
    /// A publisher that publishes elements specified by a range in the sequence of published elements.
    public struct Output<Upstream: Publisher>: Publisher {
        public typealias Output = Upstream.Output
        public typealias Failure = Upstream.Failure

        /// The publisher that this publisher receives elements from.
        public let upstream: Upstream

        /// The range of elements to publish.
        public let range: CountableRange<Int>

        /// Creates a publisher that publishes elements specified by a range.
        ///
        /// - Parameters:
        ///   - upstream: The publisher that this publisher receives elements from.
        ///   - range: The range of elements to publish.
        public init(upstream: Upstream, range: CountableRange<Int>) {
            self.upstream = upstream
            self.range = range
        }

        public func receive<S: Subscriber>(subscriber: S) where Upstream.Failure == S.Failure, Upstream.Output == S.Input {
            var didSendRequest = false
            var index = 0
            let nestedSubscriber = TransformingSubscriber<Output, Failure, Output, Failure>(
                subscriber: subscriber,
                transformRequest: { demand in
                    guard demand > .none, !didSendRequest else {
                        return [.demand(demand)]
                    }
                    didSendRequest = true
                    return [.demand(demand + self.range.lowerBound)]
                },
                transformValue: { value in
                    defer {
                        index += 1
                    }
                    if index < self.range.lowerBound {
                        return [.demand(.max(self.range.lowerBound - index))]
                    } else if index < self.range.upperBound - 1 {
                        return [.value(value)]
                    } else if index < self.range.upperBound {
                        return [.value(value), .finished]
                    } else {
                        return [.finished]
                    }
                },
                transformCompletion: {
                    switch $0 {
                    case .finished:
                        return [.finished]
                    case let .failure(error):
                        return [.failure(error)]
                    }
                }
            )

            upstream.subscribe(nestedSubscriber)
        }
    }
}

extension Publishers.Output: Equatable where Upstream: Equatable {
}

extension Publisher {
    /// Publishes a specific element, indicated by its index in the sequence of published elements.
    ///
    /// If the publisher completes normally or with an error before publishing the specified element, then the publisher doesn’t produce any elements.
    /// - Parameter index: The index that indicates the element to publish.
    /// - Returns: A publisher that publishes a specific indexed element.
    public func output(at index: Int) -> Publishers.Output<Self> {
        return Publishers.Output(upstream: self, range: index..<index + 1)
    }

    /// Publishes elements specified by their range in the sequence of published elements.
    ///
    /// After all elements are published, the publisher finishes normally.
    /// If the publisher completes normally or with an error before producing all the elements in the range, it doesn’t publish the remaining elements.
    /// - Parameter range: A range that indicates which elements to publish.
    /// - Returns: A publisher that publishes elements specified by a range.
    public func output<R: RangeExpression>(in range: R) -> Publishers.Output<Self> where R.Bound == Int {
        return Publishers.Output(upstream: self, range: CountableRange(uncheckedRange: range))
    }
}

extension Publisher {
    /// Republishes elements up to the specified maximum count.
    ///
    /// - Parameter maxLength: The maximum number of elements to republish.
    /// - Returns: A publisher that publishes up to the specified number of elements before completing.
    public func prefix(_ maxLength: Int) -> Publishers.Output<Self> {
        return Publishers.Output(upstream: self, range: 0..<maxLength)
    }
}
