extension Publishers {
    /// A publisher that publishes an optional value to each subscriber exactly once, if the optional has a value.
    ///
    /// If `result` is `.success`, and the value is non-nil, then `Optional` waits until receiving a request for at least 1 value before sending the output. If `result` is `.failure`, then `Optional` sends the failure immediately upon subscription. If `result` is `.success` and the value is nil, then `Optional` sends `.finished` immediately upon subscription.
    ///
    /// In contrast with `Just`, an `Optional` publisher can send an error.
    /// In contrast with `Once`, an `Optional` publisher can send zero values and finish normally, or send zero values and fail with an error.
    // swiftformat:disable:next typeSugar
    public struct Optional<Output, Failure>: Publisher where Failure: Error {
        /// The result to deliver to each subscriber.
        public let result: Result<Output?, Failure>

        /// Creates a publisher to emit the optional value of a successful result, or fail with an error.
        ///
        /// - Parameter result: The result to deliver to each subscriber.
        public init(_ result: Result<Output?, Failure>) {
            self.result = result
        }

        public init(_ output: Output?) {
            self.result = Result.success(output)
        }

        public init(_ failure: Failure) {
            self.result = Result.failure(failure)
        }

        public func receive<S: Subscriber>(subscriber: S) where Output == S.Input, Failure == S.Failure {
            let sequence: [Result<Output, Failure>]
            switch self.result {
            case let .success(value):
                guard let value = value else {
                    Publishers.Empty().receive(subscriber: subscriber)
                    return
                }
                sequence = [.success(value)]
            case let .failure(error):
                sequence = [.failure(error)]
            }
            let subscription = IteratingSubscription(iterator: sequence.makeIterator(), subscriber: subscriber)
            subscriber.receive(subscription: subscription)
        }
    }
}

extension Publishers.Optional: Equatable where Output: Equatable, Failure: Equatable {
}

extension Publishers.Optional where Output: Equatable {
    // swiftformat:disable:next typeSugar
    public func contains(_ output: Output) -> Publishers.Optional<Bool, Failure> {
        return self.map { $0 == output }
    }

    // swiftformat:disable:next typeSugar
    public func removeDuplicates() -> Publishers.Optional<Output, Failure> {
        return self
    }
}

extension Publishers.Optional where Output: Comparable {
    // swiftformat:disable:next typeSugar
    public func min() -> Publishers.Optional<Output, Failure> {
        return self
    }

    // swiftformat:disable:next typeSugar
    public func max() -> Publishers.Optional<Output, Failure> {
        return self
    }
}

extension Publishers.Optional {
    // swiftformat:disable:next typeSugar
    public func allSatisfy(_ predicate: (Output) -> Bool) -> Publishers.Optional<Bool, Failure> {
        return self.map(predicate)
    }

    // swiftformat:disable:next typeSugar
    public func tryAllSatisfy(_ predicate: (Output) throws -> Bool) -> Publishers.Optional<Bool, Error> {
        return self.tryMap(predicate)
    }

    // swiftformat:disable:next typeSugar
    public func collect() -> Publishers.Optional<[Output], Failure> {
        return self.map { [$0] }
    }

    // swiftformat:disable:next typeSugar
    public func compactMap<T>(_ transform: (Output) -> T?) -> Publishers.Optional<T, Failure> {
        return Publishers.Optional(self.result.map { output in
            guard let output = output else {
                return nil
            }
            return transform(output)
        })
    }

    // swiftformat:disable:next typeSugar
    public func tryCompactMap<T>(_ transform: (Output) throws -> T?) -> Publishers.Optional<T, Error> {
        switch self.result {
        case let .failure(error):
            return Publishers.Optional(error)
        case let .success(value):
            guard let value = value else {
                return Publishers.Optional(nil)
            }
            do {
                return try Publishers.Optional(transform(value))
            } catch {
                return Publishers.Optional(error)
            }
        }
    }

    // swiftformat:disable:next typeSugar
    public func min(by _: (Output, Output) -> Bool) -> Publishers.Optional<Output, Failure> {
        return self
    }

    // swiftformat:disable:next typeSugar
    public func tryMin(by _: (Output, Output) throws -> Bool) -> Publishers.Optional<Output, Failure> {
        return self
    }

    // swiftformat:disable:next typeSugar
    public func max(by _: (Output, Output) -> Bool) -> Publishers.Optional<Output, Failure> {
        return self
    }

    // swiftformat:disable:next typeSugar
    public func tryMax(by _: (Output, Output) throws -> Bool) -> Publishers.Optional<Output, Failure> {
        return self
    }

    // swiftformat:disable:next typeSugar
    public func contains(where predicate: (Output) -> Bool) -> Publishers.Optional<Bool, Failure> {
        return self.map(predicate)
    }

    // swiftformat:disable:next typeSugar
    public func tryContains(where predicate: (Output) throws -> Bool) -> Publishers.Optional<Bool, Error> {
        return self.tryMap(predicate)
    }

    // swiftformat:disable:next typeSugar
    public func count() -> Publishers.Optional<Int, Failure> {
        return Publishers.Optional(self.result.map { $0 == nil ? 0 : 1 })
    }

    // swiftformat:disable:next typeSugar
    public func dropFirst(_ count: Int = 1) -> Publishers.Optional<Output, Failure> {
        if count <= 0 {
            return self
        }
        return self.compactMap { _ in nil }
    }

    // swiftformat:disable:next typeSugar
    public func drop(while predicate: (Output) -> Bool) -> Publishers.Optional<Output, Failure> {
        return self.filter { !predicate($0) }
    }

    // swiftformat:disable:next typeSugar
    public func tryDrop(while predicate: (Output) throws -> Bool) -> Publishers.Optional<Output, Error> {
        return self.tryFilter { try !predicate($0) }
    }

    // swiftformat:disable:next typeSugar
    public func first() -> Publishers.Optional<Output, Failure> {
        return self
    }

    // swiftformat:disable:next typeSugar
    public func first(where predicate: (Output) -> Bool) -> Publishers.Optional<Output, Failure> {
        return self.filter(predicate)
    }

    // swiftformat:disable:next typeSugar
    public func tryFirst(where predicate: (Output) throws -> Bool) -> Publishers.Optional<Output, Error> {
        return self.tryFilter(predicate)
    }

    // swiftformat:disable:next typeSugar
    public func last() -> Publishers.Optional<Output, Failure> {
        return self
    }

    // swiftformat:disable:next typeSugar
    public func last(where predicate: (Output) -> Bool) -> Publishers.Optional<Output, Failure> {
        return self.first(where: predicate)
    }

    // swiftformat:disable:next typeSugar
    public func tryLast(where predicate: (Output) throws -> Bool) -> Publishers.Optional<Output, Error> {
        return self.tryFirst(where: predicate)
    }

    // swiftformat:disable:next typeSugar
    public func filter(_ isIncluded: (Output) -> Bool) -> Publishers.Optional<Output, Failure> {
        return self.compactMap { value in
            isIncluded(value) ? value : nil
        }
    }

    // swiftformat:disable:next typeSugar
    public func tryFilter(_ isIncluded: (Output) throws -> Bool) -> Publishers.Optional<Output, Error> {
        return self.tryCompactMap { value in
            try isIncluded(value) ? value : nil
        }
    }

    public func ignoreOutput() -> Publishers.Empty<Output, Failure> {
        return Publishers.Empty()
    }

    // swiftformat:disable:next typeSugar
    public func map<T>(_ transform: (Output) -> T) -> Publishers.Optional<T, Failure> {
        return self.compactMap(transform)
    }

    // swiftformat:disable:next typeSugar
    public func tryMap<T>(_ transform: (Output) throws -> T) -> Publishers.Optional<T, Error> {
        return self.tryCompactMap(transform)
    }

    // swiftformat:disable:next typeSugar
    public func mapError<E>(_ transform: (Failure) -> E) -> Publishers.Optional<Output, E> where E: Error {
        return Publishers.Optional(self.result.mapError(transform))
    }

    // swiftformat:disable:next typeSugar
    public func output(at index: Int) -> Publishers.Optional<Output, Failure> {
        return self.output(in: index...index)
    }

    // swiftformat:disable:next typeSugar
    public func output<R: RangeExpression>(in range: R) -> Publishers.Optional<Output, Failure> where R.Bound == Int {
        return range.contains(0) ? self : self.dropFirst()
    }

    // swiftformat:disable:next typeSugar
    public func prefix(_ maxLength: Int) -> Publishers.Optional<Output, Failure> {
        return maxLength > 0 ? self : self.dropFirst()
    }

    // swiftformat:disable:next typeSugar
    public func prefix(while predicate: (Output) -> Bool) -> Publishers.Optional<Output, Failure> {
        return self.filter(predicate)
    }

    // swiftformat:disable:next typeSugar
    public func tryPrefix(while predicate: (Output) throws -> Bool) -> Publishers.Optional<Output, Error> {
        return self.tryFilter(predicate)
    }

    // swiftformat:disable:next typeSugar
    public func reduce<T>(_ initialResult: T, _ nextPartialResult: (T, Output) -> T) -> Publishers.Optional<T, Failure> {
        return self.map { nextPartialResult(initialResult, $0) }
    }

    // swiftformat:disable:next typeSugar
    public func tryReduce<T>(_ initialResult: T, _ nextPartialResult: (T, Output) throws -> T) -> Publishers.Optional<T, Error> {
        return self.tryMap { try nextPartialResult(initialResult, $0) }
    }

    // swiftformat:disable:next typeSugar
    public func removeDuplicates(by _: (Output, Output) -> Bool) -> Publishers.Optional<Output, Failure> {
        return self
    }

    // swiftformat:disable:next typeSugar
    public func tryRemoveDuplicates(by _: (Output, Output) throws -> Bool) -> Publishers.Optional<Output, Error> {
        return Publishers.Optional(result.mapError { $0 })
    }

    // swiftformat:disable:next typeSugar
    public func replaceError(with output: Output) -> Publishers.Optional<Output, Never> {
        switch self.result {
        case let .success(value):
            return Publishers.Optional(value)
        case .failure:
            return Publishers.Optional(output)
        }
    }

    // swiftformat:disable:next typeSugar
    public func replaceEmpty(with output: Output) -> Publishers.Optional<Output, Failure> {
        switch self.result {
        case let .success(value):
            // swiftformat:disable:next typeSugar
            return Publishers.Optional(value ?? output)
        case .failure:
            return self
        }
    }

    // swiftformat:disable:next typeSugar
    public func retry(_: Int) -> Publishers.Optional<Output, Failure> {
        return self
    }

    // swiftformat:disable:next typeSugar
    public func retry() -> Publishers.Optional<Output, Failure> {
        return self
    }

    // swiftformat:disable:next typeSugar
    public func scan<T>(_ initialResult: T, _ nextPartialResult: (T, Output) -> T) -> Publishers.Optional<T, Failure> {
        return self.reduce(initialResult, nextPartialResult)
    }

    // swiftformat:disable:next typeSugar
    public func tryScan<T>(_ initialResult: T, _ nextPartialResult: (T, Output) throws -> T) -> Publishers.Optional<T, Error> {
        return self.tryReduce(initialResult, nextPartialResult)
    }
}

extension Publishers.Optional where Failure == Never {
    // swiftformat:disable:next typeSugar
    public func setFailureType<E>(to _: E.Type) -> Publishers.Optional<Output, E> where E: Error {
        return Publishers.Optional(try! self.result.get())
    }
}
