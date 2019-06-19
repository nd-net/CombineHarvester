
extension Publishers {
    /// A publisher that publishes an output to each subscriber exactly once then finishes, or fails immediately without producing any elements.
    ///
    /// If `result` is `.success`, then `Once` waits until it receives a request for at least 1 value before sending the output. If `result` is `.failure`, then `Once` sends the failure immediately upon subscription.
    ///
    /// In contrast with `Just`, a `Once` publisher can terminate with an error instead of sending a value.
    /// In contrast with `Optional`, a `Once` publisher always sends one value (unless it terminates with an error).
    public struct Once<Output, Failure>: Publisher where Failure: Error {
        /// The result to deliver to each subscriber.
        public let result: Result<Output, Failure>

        /// Creates a publisher that delivers the specified result.
        ///
        /// If the result is `.success`, the `Once` publisher sends the specified output to all subscribers and finishes normally. If the result is `.failure`, then the publisher fails immediately with the specified error.
        /// - Parameter result: The result to deliver to each subscriber.
        public init(_ result: Result<Output, Failure>) {
            self.result = result
        }

        /// Creates a publisher that sends the specified output to all subscribers and finishes normally.
        ///
        /// - Parameter output: The output to deliver to each subscriber.
        public init(_ output: Output) {
            self.result = .success(output)
        }

        /// Creates a publisher that immediately terminates upon subscription with the given failure.
        ///
        /// - Parameter failure: The failure to send when terminating.
        public init(_ failure: Failure) {
            self.result = .failure(failure)
        }

        public func receive<S>(subscriber: S) where Output == S.Input, Failure == S.Failure, S: Subscriber {
            let sequence: [Result<Output, Failure>] = [
                result,
            ]
            let subscription = IteratingSubscription(iterator: sequence.makeIterator(), subscriber: subscriber)
            subscriber.receive(subscription: subscription)
        }
    }
}

extension Publishers.Once: Equatable where Output: Equatable, Failure: Equatable {
    public static func == (lhs: Publishers.Once<Output, Failure>, rhs: Publishers.Once<Output, Failure>) -> Bool {
        return lhs.result == rhs.result
    }
}

extension Publishers.Once where Output: Equatable {
    public func contains(_ output: Output) -> Publishers.Once<Bool, Failure> {
        return self.map { value in output == value }
    }

    public func removeDuplicates() -> Publishers.Once<Output, Failure> {
        return self
    }
}

extension Publishers.Once where Output: Comparable {
    public func min() -> Publishers.Once<Output, Failure> {
        return self
    }

    public func max() -> Publishers.Once<Output, Failure> {
        return self
    }
}

extension Publishers.Once {
    public func allSatisfy(_ predicate: (Output) -> Bool) -> Publishers.Once<Bool, Failure> {
        return self.map(predicate)
    }

    public func tryAllSatisfy(_ predicate: (Output) throws -> Bool) -> Publishers.Once<Bool, Error> {
        return self.tryMap(predicate)
    }

    public func collect() -> Publishers.Once<[Output], Failure> {
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

    public func min(by _: (Output, Output) -> Bool) -> Publishers.Once<Output, Failure> {
        return self
    }

    public func tryMin(by _: (Output, Output) throws -> Bool) -> Publishers.Once<Output, Failure> {
        return self
    }

    public func max(by _: (Output, Output) -> Bool) -> Publishers.Once<Output, Failure> {
        return self
    }

    public func tryMax(by _: (Output, Output) throws -> Bool) -> Publishers.Once<Output, Failure> {
        return self
    }

    public func contains(where predicate: (Output) -> Bool) -> Publishers.Once<Bool, Failure> {
        return self.map(predicate)
    }

    public func tryContains(where predicate: (Output) throws -> Bool) -> Publishers.Once<Bool, Error> {
        return self.tryMap(predicate)
    }

    public func count() -> Publishers.Once<Int, Failure> {
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

    public func first() -> Publishers.Once<Output, Failure> {
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

    public func last() -> Publishers.Once<Output, Failure> {
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

    public func map<T>(_ transform: (Output) -> T) -> Publishers.Once<T, Failure> {
        return Publishers.Once(self.result.map(transform))
    }

    public func tryMap<T>(_ transform: (Output) throws -> T) -> Publishers.Once<T, Error> {
        switch self.result {
        case let .failure(error):
            return Publishers.Once(error)
        case let .success(value):
            do {
                return Publishers.Once(try transform(value))
            } catch {
                return Publishers.Once(error)
            }
        }
    }

    public func mapError<E>(_ transform: (Failure) -> E) -> Publishers.Once<Output, E> where E: Error {
        return Publishers.Once(self.result.mapError(transform))
    }

    // swiftformat:disable:next typeSugar
    public func output(at index: Int) -> Publishers.Optional<Output, Failure> {
        return self.output(in: index...index)
    }

    // swiftformat:disable:next typeSugar
    public func output<R>(in range: R) -> Publishers.Optional<Output, Failure> where R: RangeExpression, R.Bound == Int {
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

    public func reduce<T>(_ initialResult: T, _ nextPartialResult: (T, Output) -> T) -> Publishers.Once<T, Failure> {
        return self.map { nextPartialResult(initialResult, $0) }
    }

    public func tryReduce<T>(_ initialResult: T, _ nextPartialResult: (T, Output) throws -> T) -> Publishers.Once<T, Error> {
        return self.tryMap { try nextPartialResult(initialResult, $0) }
    }

    public func removeDuplicates(by _: (Output, Output) -> Bool) -> Publishers.Once<Output, Failure> {
        return self
    }

    public func tryRemoveDuplicates(by _: (Output, Output) throws -> Bool) -> Publishers.Once<Output, Error> {
        switch self.result {
        case let .failure(error):
            return Publishers.Once(error)
        case let .success(value):
            return Publishers.Once(value)
        }
    }

    public func replaceError(with output: Output) -> Publishers.Once<Output, Never> {
        return Publishers.Once(self.result.flatMapError { _ in Result.success(output) })
    }

    public func replaceEmpty(with _: Output) -> Publishers.Once<Output, Failure> {
        return self
    }

    public func retry(_: Int) -> Publishers.Once<Output, Failure> {
        return self
    }

    public func retry() -> Publishers.Once<Output, Failure> {
        return self
    }

    public func scan<T>(_ initialResult: T, _ nextPartialResult: (T, Output) -> T) -> Publishers.Once<T, Failure> {
        return self.reduce(initialResult, nextPartialResult)
    }

    public func tryScan<T>(_ initialResult: T, _ nextPartialResult: (T, Output) throws -> T) -> Publishers.Once<T, Error> {
        return self.tryReduce(initialResult, nextPartialResult)
    }
}

extension Publishers.Once where Failure == Never {
    public func setFailureType<E>(to _: E.Type) -> Publishers.Once<Output, E> where E: Error {
        return Publishers.Once(try! self.result.get())
    }
}
