extension Optional {
    typealias Publisher = OptionalPublisher
    /// A publisher that publishes an optional value to each subscriber exactly once, if the optional has a value.
    ///
    /// In contrast with `Just`, an `Optional` publisher may send no value before completion.

    public struct OptionalPublisher: CombineHarvester.Publisher {
        public typealias Output = Wrapped
        public typealias Failure = Never

        public let output: Wrapped?

        public init(_ output: Wrapped?) {
            self.output = output
        }

        public func receive<S: Subscriber>(subscriber: S) where Output == S.Input, Failure == S.Failure {
            let sequence: [Result<Output, Failure>]
            if let output = self.output {
                sequence = [.success(output)]
            } else {
                sequence = []
            }
            let subscription = IteratingSubscription(iterator: sequence.makeIterator(), subscriber: subscriber)
            subscriber.receive(subscription: subscription)
        }
    }
}

extension Optional.OptionalPublisher: Equatable where Output: Equatable {
}

extension Optional.OptionalPublisher where Output: Equatable {
    public func contains(_ output: Output) -> Optional<Bool>.OptionalPublisher {
        return self.map { $0 == output }
    }

    public func removeDuplicates() -> Optional<Output>.OptionalPublisher {
        return self
    }
}

extension Optional.OptionalPublisher where Output: Comparable {
    public func min() -> Optional<Output>.OptionalPublisher {
        return self
    }

    public func max() -> Optional<Output>.OptionalPublisher {
        return self
    }
}

extension Optional.OptionalPublisher {
    public func allSatisfy(_ predicate: (Output) -> Bool) -> Optional<Bool>.OptionalPublisher {
        return self.map(predicate)
    }

    public func collect() -> Optional<[Output]>.OptionalPublisher {
        return self.map { [$0] }
    }

    public func compactMap<T>(_ transform: (Output) -> T?) -> Optional<T>.OptionalPublisher {
        let result = self.output.flatMap(transform)
        return Optional<T>.OptionalPublisher(result)
    }

    public func min(by _: (Output, Output) -> Bool) -> Optional<Output>.OptionalPublisher {
        return self
    }

    public func max(by _: (Output, Output) -> Bool) -> Optional<Output>.OptionalPublisher {
        return self
    }

    public func contains(where predicate: (Output) -> Bool) -> Optional<Bool>.OptionalPublisher {
        return self.map(predicate)
    }

    public func count() -> Just<Int> {
        return Just(self.output == nil ? 0 : 1)
    }

    public func dropFirst(_ count: Int = 1) -> Optional<Output>.OptionalPublisher {
        if count <= 0 {
            return self
        }
        return Optional.OptionalPublisher(nil)
    }

    public func drop(while predicate: (Output) -> Bool) -> Optional<Output>.OptionalPublisher {
        return self.filter { !predicate($0) }
    }

    public func first() -> Optional<Output>.OptionalPublisher {
        return self
    }

    public func first(where predicate: (Output) -> Bool) -> Optional<Output>.OptionalPublisher {
        return self.filter(predicate)
    }

    public func last() -> Optional<Output>.OptionalPublisher {
        return self
    }

    public func last(where predicate: (Output) -> Bool) -> Optional<Output>.OptionalPublisher {
        return self.first(where: predicate)
    }

    public func filter(_ isIncluded: (Output) -> Bool) -> Optional<Output>.OptionalPublisher {
        return self.compactMap { value in
            isIncluded(value) ? value : nil
        }
    }

    public func ignoreOutput() -> Publishers.Empty<Output, Failure> {
        return Publishers.Empty()
    }

    public func map<T>(_ transform: (Output) -> T) -> Optional<T>.OptionalPublisher {
        return self.compactMap(transform)
    }

    public func output(at index: Int) -> Optional<Output>.OptionalPublisher {
        return self.output(in: index...index)
    }

    public func output<R: RangeExpression>(in range: R) -> Optional<Output>.OptionalPublisher where R.Bound == Int {
        return range.contains(0) ? self : self.dropFirst()
    }

    public func prefix(_ maxLength: Int) -> Optional<Output>.OptionalPublisher {
        return maxLength > 0 ? self : self.dropFirst()
    }

    public func prefix(while predicate: (Output) -> Bool) -> Optional<Output>.OptionalPublisher {
        return self.filter(predicate)
    }

    public func reduce<T>(_ initialResult: T, _ nextPartialResult: (T, Output) -> T) -> Optional<T>.OptionalPublisher {
        return self.map { nextPartialResult(initialResult, $0) }
    }

    public func removeDuplicates(by _: (Output, Output) -> Bool) -> Optional<Output>.OptionalPublisher {
        return self
    }

    public func replaceEmpty(with output: Output) -> Just<Output> {
        return Just(self.output ?? output)
    }

    public func retry(_: Int) -> Optional<Output>.OptionalPublisher {
        return self
    }

    public func retry() -> Optional<Output>.OptionalPublisher {
        return self
    }

    public func scan<T>(_ initialResult: T, _ nextPartialResult: (T, Output) -> T) -> Optional<T>.OptionalPublisher {
        return self.reduce(initialResult, nextPartialResult)
    }
}
