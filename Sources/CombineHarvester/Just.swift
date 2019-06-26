extension Publishers {
    /// A publisher that emits an output to each subscriber just once, and then finishes.
    ///
    /// You can use a `Just` publisher to start a chain of publishers. A `Just` publisher is also useful when replacing a value with `Catch`.
    ///
    /// In contrast with `Publishers.Once`, a `Just` publisher cannot fail with an error.
    /// In contrast with `Publishers.Optional`, a `Just` publisher always produces a value.
    public struct Just<Output>: Publisher {
        public typealias Failure = Never

        /// The one element that the publisher emits.
        public let output: Output

        /// Initializes a publisher that emits the specified output just once.
        ///
        /// - Parameter output: The one element that the publisher emits.
        public init(_ output: Output) {
            self.output = output
        }

        public func receive<S>(subscriber: S) where Output == S.Input, S: Subscriber, S.Failure == Failure {
            let sequence: [Result<Output, Failure>] = [
                .success(output),
            ]
            let subscription = IteratingSubscription(iterator: sequence.makeIterator(), subscriber: subscriber)
            subscriber.receive(subscription: subscription)
        }
    }
}

extension Publishers.Just: Equatable where Output: Equatable {
}

extension Publishers.Just where Output: Comparable {
    public func min() -> Publishers.Just<Output> {
        return self
    }

    public func max() -> Publishers.Just<Output> {
        return self
    }
}

extension Publishers.Just where Output: Equatable {
    public func contains(_ output: Output) -> Publishers.Just<Bool> {
        return Publishers.Just(self.output == output)
    }

    public func removeDuplicates() -> Publishers.Just<Output> {
        return self
    }
}

extension Publishers.Just {
    public func allSatisfy(_ predicate: (Output) -> Bool) -> Publishers.Just<Bool> {
        return self.map(predicate)
    }

    public func tryAllSatisfy(_ predicate: (Output) throws -> Bool) -> Publishers.Once<Bool, Error> {
        return self.tryMap(predicate)
    }

    public func collect() -> Publishers.Just<[Output]> {
        return self.map { [$0] }
    }

    // swiftformat:disable:next typeSugar
    public func compactMap<T>(_ transform: (Output) -> T?) -> Publishers.Optional<T, Failure> {
        // swiftformat:disable:next typeSugar
        return Publishers.Optional(transform(self.output))
    }

    // swiftformat:disable:next typeSugar
    public func tryCompactMap<T>(_ transform: (Output) throws -> T?) -> Publishers.Optional<T, Error> {
        do {
            // swiftformat:disable:next typeSugar
            return Publishers.Optional(try transform(self.output))
        } catch {
            // swiftformat:disable:next typeSugar
            return Publishers.Optional(error)
        }
    }

    public func min(by _: (Output, Output) -> Bool) -> Publishers.Just<Output> {
        return self
    }

    public func tryMin(by _: (Output, Output) throws -> Bool) -> Publishers.Just<Output> {
        return self
    }

    public func max(by _: (Output, Output) -> Bool) -> Publishers.Just<Output> {
        return self
    }

    public func tryMax(by _: (Output, Output) throws -> Bool) -> Publishers.Just<Output> {
        return self
    }

    public func prepend(_ elements: Output...) -> Publishers.Sequence<[Output], Failure> {
        return Publishers.Sequence(sequence: elements + [output])
    }

    public func prepend<S>(_ elements: S) -> Publishers.Sequence<[Output], Failure> where Output == S.Element, S: Swift.Sequence {
        return Publishers.Sequence(sequence: elements + [output])
    }

    public func append(_ elements: Output...) -> Publishers.Sequence<[Output], Failure> {
        return Publishers.Sequence(sequence: [output] + elements)
    }

    public func append<S>(_ elements: S) -> Publishers.Sequence<[Output], Failure> where Output == S.Element, S: Swift.Sequence {
        return Publishers.Sequence(sequence: [output] + elements)
    }

    public func contains(where predicate: (Output) -> Bool) -> Publishers.Just<Bool> {
        return self.map(predicate)
    }

    public func tryContains(where predicate: (Output) throws -> Bool) -> Publishers.Once<Bool, Error> {
        return self.tryMap(predicate)
    }

    public func count() -> Publishers.Just<Int> {
        return Publishers.Just(1)
    }

    // swiftformat:disable:next typeSugar
    public func dropFirst(_ count: Int = 1) -> Publishers.Optional<Output, Failure> {
        // swiftformat:disable:next typeSugar
        return Publishers.Optional(count <= 0 ? self.output : nil)
    }

    // swiftformat:disable:next typeSugar
    public func drop(while predicate: (Output) -> Bool) -> Publishers.Optional<Output, Failure> {
        return self.filter { !predicate($0) }
    }

    // swiftformat:disable:next typeSugar
    public func tryDrop(while predicate: (Output) throws -> Bool) -> Publishers.Optional<Output, Error> {
        return self.tryFilter { try !predicate($0) }
    }

    public func first() -> Publishers.Just<Output> {
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

    public func last() -> Publishers.Just<Output> {
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
        return Publishers.Optional(isIncluded(self.output) ? self.output : nil)
    }

    // swiftformat:disable:next typeSugar
    public func tryFilter(_ isIncluded: (Output) throws -> Bool) -> Publishers.Optional<Output, Error> {
        do {
            // swiftformat:disable:next typeSugar
            return Publishers.Optional(try isIncluded(self.output) ? self.output : nil)
        } catch {
            // swiftformat:disable:next typeSugar
            return Publishers.Optional(error)
        }
    }

    public func ignoreOutput() -> Publishers.Empty<Output, Failure> {
        return Publishers.Empty()
    }

    public func map<T>(_ transform: (Output) -> T) -> Publishers.Just<T> {
        return Publishers.Just(transform(self.output))
    }

    public func tryMap<T>(_ transform: (Output) throws -> T) -> Publishers.Once<T, Error> {
        do {
            return Publishers.Once(try transform(self.output))
        } catch {
            return Publishers.Once(Result.failure(error))
        }
    }

    public func mapError<E>(_: (Failure) -> E) -> Publishers.Once<Output, E> where E: Error {
        return Publishers.Once(self.output)
    }

    // swiftformat:disable:next typeSugar
    public func output(at index: Int) -> Publishers.Optional<Output, Failure> {
        return self.output(in: index...index)
    }

    // swiftformat:disable:next typeSugar
    public func output<R>(in range: R) -> Publishers.Optional<Output, Failure> where R: RangeExpression, R.Bound == Int {
        // swiftformat:disable:next typeSugar
        return Publishers.Optional(range.contains(0) ? self.output : nil)
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
        return Publishers.Once(nextPartialResult(initialResult, self.output))
    }

    public func tryReduce<T>(_ initialResult: T, _ nextPartialResult: (T, Output) throws -> T) -> Publishers.Once<T, Error> {
        return self.tryMap { try nextPartialResult(initialResult, $0) }
    }

    public func removeDuplicates(by _: (Output, Output) -> Bool) -> Publishers.Just<Output> {
        return self
    }

    public func tryRemoveDuplicates(by _: (Output, Output) throws -> Bool) -> Publishers.Once<Output, Error> {
        return Publishers.Once(self.output)
    }

    public func replaceError(with _: Output) -> Publishers.Just<Output> {
        return self
    }

    public func replaceEmpty(with _: Output) -> Publishers.Just<Output> {
        return self
    }

    public func retry(_: Int) -> Publishers.Just<Output> {
        return self
    }

    public func retry() -> Publishers.Just<Output> {
        return self
    }

    public func scan<T>(_ initialResult: T, _ nextPartialResult: (T, Output) -> T) -> Publishers.Once<T, Failure> {
        return self.reduce(initialResult, nextPartialResult)
    }

    public func tryScan<T>(_ initialResult: T, _ nextPartialResult: (T, Output) throws -> T) -> Publishers.Once<T, Error> {
        return self.tryReduce(initialResult, nextPartialResult)
    }

    public func setFailureType<E>(to _: E.Type) -> Publishers.Once<Output, E> where E: Error {
        return Publishers.Once(self.output)
    }
}
