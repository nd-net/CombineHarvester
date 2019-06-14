
extension Publishers {
    /// A publisher that emits an output to each subscriber just once, and then finishes.
    ///
    /// You can use a `Just` publisher to start a chain of publishers. A `Just` publisher is also useful when replacing a value with `Catch`.
    ///
    /// In contrast with `Publishers.Once`, a `Just` publisher cannot fail with an error.
    /// In contrast with `Publishers.Optional`, a `Just` publisher always produces a value.
    public struct Just<Output>: Publisher {
        /// The kind of errors this publisher might publish.
        ///
        /// Use `Never` if this `Publisher` does not publish errors.
        public typealias Failure = Never
        
        /// The one element that the publisher emits.
        public let output: Output
        
        /// Initializes a publisher that emits the specified output just once.
        ///
        /// - Parameter output: The one element that the publisher emits.
        public init(_ output: Output) {
            self.output = output }
        
        /// This function is called to attach the specified `Subscriber` to this `Publisher` by `subscribe(_:)`
        ///
        /// - SeeAlso: `subscribe(_:)`
        /// - Parameters:
        ///     - subscriber: The subscriber to attach to this `Publisher`.
        ///                   once attached it can begin to receive values.
        public func receive<S>(subscriber: S) where Output == S.Input, S: Subscriber, S.Failure == Publishers.Just<Output>.Failure { notImplemented() }
    }
}

extension Publishers.Just: Equatable where Output: Equatable {
    /// Returns a Boolean value indicating whether two values are equal.
    ///
    /// Equality is the inverse of inequality. For any values `a` and `b`,
    /// `a == b` implies that `a != b` is `false`.
    ///
    /// - Parameters:
    ///   - lhs: A value to compare.
    ///   - rhs: Another value to compare.
    public static func == (lhs: Publishers.Just<Output>, rhs: Publishers.Just<Output>) -> Bool {
        return lhs.output == rhs.output
    }
}

extension Publishers.Just where Output: Comparable {
    public func min() -> Publishers.Just<Output> {
        return self
    }
    
    public func max() -> Publishers.Just<Output> {
    return self }
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
    
    public func tryAllSatisfy(_ predicate: (Output) throws -> Bool) -> Publishers.Once<Bool, Error>{
        return self.tryMap(predicate)
    }
    
    public func collect() -> Publishers.Just<[Output]> {
        return self.map({[$0]})
    }
    
    public func compactMap<T>(_ transform: (Output) -> T?) -> Publishers.Optional<T, Publishers.Just<Output>.Failure> {
        if let result = transform(self.output) {
            return Publishers.Optional(result)
        } else {
            return Publishers.Optional(nil)
        }
    }
    
    public func tryCompactMap<T>(_ transform: (Output) throws -> T?) -> Publishers.Optional<T, Error> {
        do {
        if let result = try transform(self.output) {
            return Publishers.Optional(result)
        } else {
            return Publishers.Optional(nil)
        }
        } catch {
            return Publishers.Optional(error)
        }
    }
    
    public func min(by areInIncreasingOrder: (Output, Output) -> Bool) -> Publishers.Just<Output>{
        return self
    }
    
    public func tryMin(by areInIncreasingOrder: (Output, Output) throws -> Bool) -> Publishers.Just<Output>{
        return self
    }
    
    public func max(by areInIncreasingOrder: (Output, Output) -> Bool) -> Publishers.Just<Output>{
        return self
    }
    
    public func tryMax(by areInIncreasingOrder: (Output, Output) throws -> Bool) -> Publishers.Just<Output>{
        return self
    }
    
    public func prepend(_ elements: Output...) -> Publishers.Sequence<[Output], Publishers.Just<Output>.Failure> {
        var sequence = elements
        sequence.append(self.output)
        return Publishers.Sequence(sequence: sequence)
    }
    
    public func prepend<S>(_ elements: S) -> Publishers.Sequence<[Output], Publishers.Just<Output>.Failure> where Output == S.Element, S : Swift.Sequence {
        notImplemented()
    }
    
    public func append(_ elements: Output...) -> Publishers.Sequence<[Output], Publishers.Just<Output>.Failure> {
        var sequence = elements
        sequence.insert(self.output, at: 0)
        notImplemented()
    }
    
    public func append<S>(_ elements: S) -> Publishers.Sequence<[Output], Publishers.Just<Output>.Failure> where Output == S.Element, S : Sequence {
        notImplemented()
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
    
    public func dropFirst(_ count: Int = 1) -> Publishers.Optional<Output, Publishers.Just<Output>.Failure> {
        return Publishers.Optional(count <= 0 ? self.output : nil)
    }
    
    public func drop(while predicate: (Output) -> Bool) -> Publishers.Optional<Output, Publishers.Just<Output>.Failure> {
        return self.filter(predicate)
    }
    
    public func tryDrop(while predicate: (Output) throws -> Bool) -> Publishers.Optional<Output, Error> {
        return self.tryFilter(predicate)
    }
    
    public func first() -> Publishers.Just<Output> {
        return self
    }
    
    public func first(where predicate: (Output) -> Bool) -> Publishers.Optional<Output, Publishers.Just<Output>.Failure> {
        return self.filter(predicate)
    }
    
    public func tryFirst(where predicate: (Output) throws -> Bool) -> Publishers.Optional<Output, Error> {
        return self.tryFilter(predicate)
    }
    
    public func last() -> Publishers.Just<Output> {
        return self
    }
    
    public func last(where predicate: (Output) -> Bool) -> Publishers.Optional<Output, Publishers.Just<Output>.Failure> {
        return self.filter(predicate)
    }
    
    public func tryLast(where predicate: (Output) throws -> Bool) -> Publishers.Optional<Output, Error> {
        return self.tryFilter(predicate)
    }
    
    public func filter(_ isIncluded: (Output) -> Bool) -> Publishers.Optional<Output, Publishers.Just<Output>.Failure> {
        return Publishers.Optional(isIncluded(self.output) ? self.output : nil)
    }
    
    public func tryFilter(_ isIncluded: (Output) throws -> Bool) -> Publishers.Optional<Output, Error> {
        do {
        return Publishers.Optional(try isIncluded(self.output) ? self.output : nil)
        } catch {
            return Publishers.Optional(error)
        }
    }
    
    public func ignoreOutput() -> Publishers.Empty<Output, Publishers.Just<Output>.Failure>{
        return Publishers.Empty()
    }
    
    public func map<T>(_ transform: (Output) -> T) -> Publishers.Just<T> {
        return Publishers.Just(transform(self.output))
    }
    
    public func tryMap<T>(_ transform: (Output) throws -> T) -> Publishers.Once<T, Error> {
        do {
        return Publishers.Once(try transform(output))
        } catch {
            return Publishers.Once(Result.failure(error))
        }
    }
    
    public func mapError<E>(_ transform: (Publishers.Just<Output>.Failure) -> E) -> Publishers.Once<Output, E> where E : Error {
        return Publishers.Once(self.output)
    }
    
    public func output(at index: Int) -> Publishers.Optional<Output, Publishers.Just<Output>.Failure> {
        return self.output(in: index...index)
    }
    
    public func output<R>(in range: R) -> Publishers.Optional<Output, Publishers.Just<Output>.Failure> where R : RangeExpression, R.Bound == Int {
        return Publishers.Optional(range.contains(0) ? self.output : nil)
    }
    
    public func prefix(_ maxLength: Int) -> Publishers.Optional<Output, Publishers.Just<Output>.Failure> {
        return self.output(in: 0..<maxLength)
    }
    
    public func prefix(while predicate: (Output) -> Bool) -> Publishers.Optional<Output, Publishers.Just<Output>.Failure> {
        return self.filter(predicate)
    }
    
    public func tryPrefix(while predicate: (Output) throws -> Bool) -> Publishers.Optional<Output, Error>{
        return self.tryFilter(predicate)
    }
    
    public func reduce<T>(_ initialResult: T, _ nextPartialResult: (T, Output) -> T) -> Publishers.Once<T, Publishers.Just<Output>.Failure> {
        return Publishers.Once(nextPartialResult(initialResult,output))
    }
    
    public func tryReduce<T>(_ initialResult: T, _ nextPartialResult: (T, Output) throws -> T) -> Publishers.Once<T, Error> {
        return self.tryMap({try nextPartialResult(initialResult,$0)})
    }
    
    public func removeDuplicates(by predicate: (Output, Output) -> Bool) -> Publishers.Just<Output>{
        return self
    }
    
    public func tryRemoveDuplicates(by predicate: (Output, Output) throws -> Bool) -> Publishers.Once<Output, Error> {
        return Publishers.Once(self.output)
    }
    
    public func replaceError(with output: Output) -> Publishers.Just<Output> {
        return self
    }
    
    public func replaceEmpty(with output: Output) -> Publishers.Just<Output> {
        return self
    }
    
    public func retry(_ times: Int) -> Publishers.Just<Output> {
        return self
    }
    
    public func retry() -> Publishers.Just<Output> {
        return self
    }
    
    public func scan<T>(_ initialResult: T, _ nextPartialResult: (T, Output) -> T) -> Publishers.Once<T, Publishers.Just<Output>.Failure> {
        return self.reduce(initialResult, nextPartialResult)
    }
    
    public func tryScan<T>(_ initialResult: T, _ nextPartialResult: (T, Output) throws -> T) -> Publishers.Once<T, Error> {
                 return self.tryReduce(initialResult, nextPartialResult)

    }
    
    public func setFailureType<E>(to failureType: E.Type) -> Publishers.Once<Output, E> where E : Error {
        return Publishers.Once(self.output)
    }
}
