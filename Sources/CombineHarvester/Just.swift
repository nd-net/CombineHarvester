/// A publisher that emits an output to each subscriber just once, and then finishes.
///
/// You can use a `Just` publisher to start a chain of publishers. A `Just` publisher is also useful when replacing a value with `Catch`.
///
/// In contrast with `Publishers.Once`, a `Just` publisher cannot fail with an error.
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

    public func receive<S: Subscriber>(subscriber: S) where Output == S.Input, S.Failure == Failure {
        let sequence: [Result<Output, Failure>] = [
            .success(output),
        ]
        let subscription = IteratingSubscription(iterator: sequence.makeIterator(), subscriber: subscriber)
        subscriber.receive(subscription: subscription)
    }
}

extension Just: Equatable where Output: Equatable {
}

extension Just where Output: Comparable {
    public func min() -> Just<Output> {
        return self
    }

    public func max() -> Just<Output> {
        return self
    }
}

extension Just where Output: Equatable {
    public func contains(_ output: Output) -> Just<Bool> {
        return Just<Bool>(self.output == output)
    }

    public func removeDuplicates() -> Just<Output> {
        return self
    }
}

extension Just {
    public func allSatisfy(_ predicate: (Output) -> Bool) -> Just<Bool> {
        return self.map(predicate)
    }

    public func tryAllSatisfy(_ predicate: (Output) throws -> Bool) -> Result<Bool, Error>.ResultPublisher {
        return self.tryMap(predicate)
    }

    public func collect() -> Just<[Output]> {
        return self.map { [$0] }
    }

    // swiftformat:disable:next typeSugar
    public func compactMap<T>(_ transform: (Output) -> T?) -> Optional<T>.OptionalPublisher {
        // swiftformat:disable:next typeSugar
        return Optional.OptionalPublisher(transform(self.output))
    }

    public func min(by _: (Output, Output) -> Bool) -> Just<Output> {
        return self
    }

    public func tryMin(by _: (Output, Output) throws -> Bool) -> Just<Output> {
        return self
    }

    public func max(by _: (Output, Output) -> Bool) -> Just<Output> {
        return self
    }

    public func tryMax(by _: (Output, Output) throws -> Bool) -> Just<Output> {
        return self
    }

    public func prepend(_ elements: Output...) -> Publishers.Sequence<[Output], Failure> {
        return Publishers.Sequence(sequence: elements + [self.output])
    }

    public func prepend<S: Swift.Sequence>(_ elements: S) -> Publishers.Sequence<[Output], Failure> where Output == S.Element {
        return Publishers.Sequence(sequence: elements + [self.output])
    }

    public func append(_ elements: Output...) -> Publishers.Sequence<[Output], Failure> {
        return Publishers.Sequence(sequence: [self.output] + elements)
    }

    public func append<S: Swift.Sequence>(_ elements: S) -> Publishers.Sequence<[Output], Failure> where Output == S.Element {
        return Publishers.Sequence(sequence: [self.output] + elements)
    }

    public func contains(where predicate: (Output) -> Bool) -> Just<Bool> {
        return self.map(predicate)
    }

    public func tryContains(where predicate: (Output) throws -> Bool) -> Result<Bool, Error>.ResultPublisher {
        return self.tryMap(predicate)
    }

    public func count() -> Just<Int> {
        return Just<Int>(1)
    }

    // swiftformat:disable:next typeSugar
    public func dropFirst(_ count: Int = 1) -> Optional<Output>.OptionalPublisher {
        // swiftformat:disable:next typeSugar
        return Optional.OptionalPublisher(count <= 0 ? self.output : nil)
    }

    // swiftformat:disable:next typeSugar
    public func drop(while predicate: (Output) -> Bool) -> Optional<Output>.OptionalPublisher {
        return self.filter { !predicate($0) }
    }

    public func first() -> Just<Output> {
        return self
    }

    // swiftformat:disable:next typeSugar
    public func first(where predicate: (Output) -> Bool) -> Optional<Output>.OptionalPublisher {
        return self.filter(predicate)
    }

    public func last() -> Just<Output> {
        return self
    }

    // swiftformat:disable:next typeSugar
    public func last(where predicate: (Output) -> Bool) -> Optional<Output>.OptionalPublisher {
        return self.filter(predicate)
    }

    // swiftformat:disable:next typeSugar
    public func filter(_ isIncluded: (Output) -> Bool) -> Optional<Output>.OptionalPublisher {
        // swiftformat:disable:next typeSugar
        return Optional.OptionalPublisher(isIncluded(self.output) ? self.output : nil)
    }

    public func ignoreOutput() -> Publishers.Empty<Output, Failure> {
        return Publishers.Empty()
    }

    public func map<T>(_ transform: (Output) -> T) -> Just<T> {
        return Just<T>(transform(self.output))
    }

    public func tryMap<T>(_ transform: (Output) throws -> T) -> Result<T, Error>.ResultPublisher {
        return Result { try transform(self.output) }.resultPublisher
    }

    public func mapError<E: Error>(_: (Failure) -> E) -> Result<Output, E>.ResultPublisher {
        return Result.success(self.output).resultPublisher
    }

    // swiftformat:disable:next typeSugar
    public func output(at index: Int) -> Optional<Output>.OptionalPublisher {
        return self.output(in: index...index)
    }

    // swiftformat:disable:next typeSugar
    public func output<R: RangeExpression>(in range: R) -> Optional<Output>.OptionalPublisher where R.Bound == Int {
        // swiftformat:disable:next typeSugar
        return Optional.OptionalPublisher(range.contains(0) ? self.output : nil)
    }

    // swiftformat:disable:next typeSugar
    public func prefix(_ maxLength: Int) -> Optional<Output>.OptionalPublisher {
        return self.output(in: 0..<maxLength)
    }

    // swiftformat:disable:next typeSugar
    public func prefix(while predicate: (Output) -> Bool) -> Optional<Output>.OptionalPublisher {
        return self.filter(predicate)
    }

    public func reduce<T>(_ initialResult: T, _ nextPartialResult: (T, Output) -> T) -> Result<T, Failure>.ResultPublisher {
        return Result.success(nextPartialResult(initialResult, self.output)).resultPublisher
    }

    public func tryReduce<T>(_ initialResult: T, _ nextPartialResult: (T, Output) throws -> T) -> Result<T, Error>.ResultPublisher {
        return self.tryMap { try nextPartialResult(initialResult, $0) }
    }

    public func removeDuplicates(by _: (Output, Output) -> Bool) -> Just<Output> {
        return self
    }

    public func tryRemoveDuplicates(by _: (Output, Output) throws -> Bool) -> Result<Output, Error>.ResultPublisher {
        return Result.success(self.output).resultPublisher
    }

    public func replaceError(with _: Output) -> Just<Output> {
        return self
    }

    public func replaceEmpty(with _: Output) -> Just<Output> {
        return self
    }

    public func retry(_: Int) -> Just<Output> {
        return self
    }

    public func scan<T>(_ initialResult: T, _ nextPartialResult: (T, Output) -> T) -> Result<T, Failure>.ResultPublisher {
        return self.reduce(initialResult, nextPartialResult)
    }

    public func tryScan<T>(_ initialResult: T, _ nextPartialResult: (T, Output) throws -> T) -> Result<T, Error>.ResultPublisher {
        return self.tryReduce(initialResult, nextPartialResult)
    }

    public func setFailureType<E: Error>(to _: E.Type) -> Result<Output, E>.ResultPublisher {
        return Result.success(self.output).resultPublisher
    }
}
