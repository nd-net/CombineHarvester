extension Result {
    typealias Publisher = ResultPublisher
    /// A publisher that publishes an output to each subscriber exactly once then finishes, or fails immediately without producing any elements.
    ///
    /// If `result` is `.success`, then `Once` waits until it receives a request for at least 1 value before sending the output. If `result` is `.failure`, then `Once` sends the failure immediately upon subscription.
    ///
    /// In contrast with `Just`, a `Once` publisher can terminate with an error instead of sending a value.
    /// In contrast with `Optional`, a `Once` publisher always sends one value (unless it terminates with an error).
    public struct ResultPublisher: CombineHarvester.Publisher {
        public typealias Output = Success
        /// The result to deliver to each subscriber.
        public let result: Result<Success, Failure>

        /// Creates a publisher that delivers the specified result.
        ///
        /// If the result is `.success`, the `Once` publisher sends the specified output to all subscribers and finishes normally. If the result is `.failure`, then the publisher fails immediately with the specified error.
        /// - Parameter result: The result to deliver to each subscriber.
        public init(_ result: Result<Success, Failure>) {
            self.result = result
        }

        /// Creates a publisher that sends the specified output to all subscribers and finishes normally.
        ///
        /// - Parameter output: The output to deliver to each subscriber.
        public init(_ output: Success) {
            self.result = .success(output)
        }

        /// Creates a publisher that immediately terminates upon subscription with the given failure.
        ///
        /// - Parameter failure: The failure to send when terminating.
        public init(_ failure: Failure) {
            self.result = .failure(failure)
        }

        public func receive<S: Subscriber>(subscriber: S) where Output == S.Input, Failure == S.Failure {
            let sequence: [Result<Output, Failure>] = [
                result,
            ]
            let subscription = IteratingSubscription(iterator: sequence.makeIterator(), subscriber: subscriber)
            subscriber.receive(subscription: subscription)
        }
    }

    public var publisher: ResultPublisher {
        return self.resultPublisher
    }

    public var resultPublisher: ResultPublisher {
        return ResultPublisher(self)
    }
}

extension Result.ResultPublisher: Equatable where Output: Equatable, Failure: Equatable {
}

extension Result.ResultPublisher where Output: Equatable {
    public func contains(_ output: Output) -> Result<Bool, Failure>.ResultPublisher {
        return self.map { value in output == value }
    }

    public func removeDuplicates() -> Result<Output, Failure>.ResultPublisher {
        return self
    }
}

extension Result.ResultPublisher where Output: Comparable {
    public func min() -> Result<Output, Failure>.ResultPublisher {
        return self
    }

    public func max() -> Result<Output, Failure>.ResultPublisher {
        return self
    }
}

extension Result.ResultPublisher {
    public func allSatisfy(_ predicate: (Output) -> Bool) -> Result<Bool, Failure>.ResultPublisher {
        return self.map(predicate)
    }

    public func tryAllSatisfy(_ predicate: (Output) throws -> Bool) -> Result<Bool, Error>.ResultPublisher {
        return self.tryMap(predicate)
    }

    public func collect() -> Result<[Output], Failure>.ResultPublisher {
        return self.map { [$0] }
    }

    // swiftformat:disable:next typeSugar
    public func compactMap<T>(_ transform: (Output) -> T?) -> Publishers.Optional<T, Failure> {
        // swiftformat:disable:next typeSugar
        return Publishers.Optional(self.result.map(transform))
    }

    // swiftformat:disable:next typeSugar
    public func tryCompactMap<T>(_ transform: (Output) throws -> T?) -> Publishers.Optional<T, Error> {
        switch self.result {
        case let .failure(failure):
            // swiftformat:disable:next typeSugar
            return Publishers.Optional(failure)
        case let .success(value):
            do {
                // swiftformat:disable:next typeSugar
                return Publishers.Optional(try transform(value))
            } catch {
                // swiftformat:disable:next typeSugar
                return Publishers.Optional(error)
            }
        }
    }

    public func min(by _: (Output, Output) -> Bool) -> Result<Output, Failure>.ResultPublisher {
        return self
    }

    public func tryMin(by _: (Output, Output) throws -> Bool) -> Result<Output, Failure>.ResultPublisher {
        return self
    }

    public func max(by _: (Output, Output) -> Bool) -> Result<Output, Failure>.ResultPublisher {
        return self
    }

    public func tryMax(by _: (Output, Output) throws -> Bool) -> Result<Output, Failure>.ResultPublisher {
        return self
    }

    public func contains(where predicate: (Output) -> Bool) -> Result<Bool, Failure>.ResultPublisher {
        return self.map(predicate)
    }

    public func tryContains(where predicate: (Output) throws -> Bool) -> Result<Bool, Error>.ResultPublisher {
        return self.tryMap(predicate)
    }

    public func count() -> Result<Int, Failure>.ResultPublisher {
        return self.map { _ in 1 }
    }

    // swiftformat:disable:next typeSugar
    public func dropFirst(_ count: Int = 1) -> Publishers.Optional<Output, Failure> {
        return self.filter { _ in count < 1 }
    }

    // swiftformat:disable:next typeSugar
    public func drop(while predicate: (Output) -> Bool) -> Publishers.Optional<Output, Failure> {
        return self.filter { !predicate($0) }
    }

    // swiftformat:disable:next typeSugar
    public func tryDrop(while predicate: (Output) throws -> Bool) -> Publishers.Optional<Output, Error> {
        return self.tryFilter { try !predicate($0) }
    }

    public func first() -> Result<Output, Failure>.ResultPublisher {
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

    public func last() -> Result<Output, Failure>.ResultPublisher {
        return self
    }

    // swiftformat:disable:next typeSugar
    public func last(where predicate: (Output) -> Bool) -> Publishers.Optional<Output, Failure> {
        return self.filter(predicate)
    }

    // swiftformat:disable:next typeSugar
    public func tryLast(where predicate: (Output) throws -> Bool) -> Publishers.Optional<Output, Error> {
        return self.tryFilter(predicate)
    }

    // swiftformat:disable:next typeSugar
    public func filter(_ isIncluded: (Output) -> Bool) -> Publishers.Optional<Output, Failure> {
        // swiftformat:disable:next typeSugar
        return Publishers.Optional(self.result.map { value in
            isIncluded(value) ? value : nil
        })
    }

    // swiftformat:disable:next typeSugar
    public func tryFilter(_ isIncluded: (Output) throws -> Bool) -> Publishers.Optional<Output, Error> {
        switch self.result {
        case let .failure(error):
            // swiftformat:disable:next typeSugar
            return Publishers.Optional(error)
        case let .success(value):
            do {
                // swiftformat:disable:next typeSugar
                return Publishers.Optional(try isIncluded(value) ? value : nil)
            } catch {
                // swiftformat:disable:next typeSugar
                return Publishers.Optional(error)
            }
        }
    }

    public func ignoreOutput() -> Publishers.Empty<Output, Failure> {
        return Publishers.Empty()
    }

    public func map<T>(_ transform: (Output) -> T) -> Result<T, Failure>.ResultPublisher {
        let mapped = self.result.map(transform)
        return mapped.resultPublisher
    }

    public func tryMap<T>(_ transform: (Output) throws -> T) -> Result<T, Error>.ResultPublisher {
        let mapped = Result<T, Error> {
            let value = try self.result.get()
            return try transform(value)
        }
        return mapped.resultPublisher
    }

    public func mapError<E: Error>(_ transform: (Failure) -> E) -> Result<Output, E>.ResultPublisher {
        return self.result.mapError(transform).resultPublisher
    }

    // swiftformat:disable:next typeSugar
    public func output(at index: Int) -> Publishers.Optional<Output, Failure> {
        return self.output(in: index...index)
    }

    // swiftformat:disable:next typeSugar
    public func output<R: RangeExpression>(in range: R) -> Publishers.Optional<Output, Failure> where R.Bound == Int {
        return self.filter { _ in range.contains(0) }
    }

    // swiftformat:disable:next typeSugar
    public func prefix(_ maxLength: Int) -> Publishers.Optional<Output, Failure> {
        return self.output(in: 0..<maxLength)
    }

    // swiftformat:disable:next typeSugar
    public func prefix(while predicate: (Output) -> Bool) -> Publishers.Optional<Output, Failure> {
        return self.filter(predicate)
    }

    // swiftformat:disable:next typeSugar
    public func tryPrefix(while predicate: (Output) throws -> Bool) -> Publishers.Optional<Output, Error> {
        return self.tryFilter(predicate)
    }

    public func reduce<T>(_ initialResult: T, _ nextPartialResult: (T, Output) -> T) -> Result<T, Failure>.ResultPublisher {
        return self.map { nextPartialResult(initialResult, $0) }
    }

    public func tryReduce<T>(_ initialResult: T, _ nextPartialResult: (T, Output) throws -> T) -> Result<T, Error>.ResultPublisher {
        return self.tryMap { try nextPartialResult(initialResult, $0) }
    }

    public func removeDuplicates(by _: (Output, Output) -> Bool) -> Result<Output, Failure>.ResultPublisher {
        return self
    }

    public func tryRemoveDuplicates(by _: (Output, Output) throws -> Bool) -> Result<Output, Error>.ResultPublisher {
        let mapped: Result<Output, Error> = self.result.mapError { $0 }
        return mapped.resultPublisher
    }

    public func replaceError(with output: Output) -> Result<Output, Never>.ResultPublisher {
        let mapped: Result<Output, Never> = self.result.flatMapError { _ in .success(output) }
        return mapped.resultPublisher
    }

    public func replaceEmpty(with _: Output) -> Result<Output, Failure>.ResultPublisher {
        return self
    }

    public func retry(_: Int) -> Result<Output, Failure>.ResultPublisher {
        return self
    }

    public func retry() -> Result<Output, Failure>.ResultPublisher {
        return self
    }

    public func scan<T>(_ initialResult: T, _ nextPartialResult: (T, Output) -> T) -> Result<T, Failure>.ResultPublisher {
        return self.reduce(initialResult, nextPartialResult)
    }

    public func tryScan<T>(_ initialResult: T, _ nextPartialResult: (T, Output) throws -> T) -> Result<T, Error>.ResultPublisher {
        return self.tryReduce(initialResult, nextPartialResult)
    }
}

extension Result.ResultPublisher where Failure == Never {
    public func setFailureType<E: Error>(to _: E.Type) -> Result<Output, E>.ResultPublisher {
        switch self.result {
        case let .success(value):
            return Result<Success, E>.success(value).resultPublisher
        }
    }
}
