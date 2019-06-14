
extension Publishers {
    
    /// A publisher that publishes an optional value to each subscriber exactly once, if the optional has a value.
    ///
    /// If `result` is `.success`, and the value is non-nil, then `Optional` waits until receiving a request for at least 1 value before sending the output. If `result` is `.failure`, then `Optional` sends the failure immediately upon subscription. If `result` is `.success` and the value is nil, then `Optional` sends `.finished` immediately upon subscription.
    ///
    /// In contrast with `Just`, an `Optional` publisher can send an error.
    /// In contrast with `Once`, an `Optional` publisher can send zero values and finish normally, or send zero values and fail with an error.
    public struct Optional<Output, Failure> : Publisher where Failure : Error {
        
        /// The result to deliver to each subscriber.
        public let result: Result<Output?, Failure>
        
        /// Creates a publisher to emit the optional value of a successful result, or fail with an error.
        ///
        /// - Parameter result: The result to deliver to each subscriber.
        public init(_ result: Result<Output?, Failure>){
            self.result = result
        }
        
        public init(_ output: Output?){
            self.result = Result.success(output)
        }
        
        public init(_ failure: Failure){
            self.result = Result.failure(failure)
        }
        
        /// This function is called to attach the specified `Subscriber` to this `Publisher` by `subscribe(_:)`
        ///
        /// - SeeAlso: `subscribe(_:)`
        /// - Parameters:
        ///     - subscriber: The subscriber to attach to this `Publisher`.
        ///                   once attached it can begin to receive values.
        public func receive<S>(subscriber: S) where Output == S.Input, Failure == S.Failure, S : Subscriber{notImplemented()}
    }
}

extension Publishers.Optional : Equatable where Output : Equatable, Failure : Equatable {
    
    /// Returns a Boolean value indicating whether two values are equal.
    ///
    /// Equality is the inverse of inequality. For any values `a` and `b`,
    /// `a == b` implies that `a != b` is `false`.
    ///
    /// - Parameters:
    ///   - lhs: A value to compare.
    ///   - rhs: Another value to compare.
    public static func == (lhs: Publishers.Optional<Output, Failure>, rhs: Publishers.Optional<Output, Failure>) -> Bool{
        return lhs.result == rhs.result
    }
}

extension Publishers.Optional where Output : Equatable {
    
    public func contains(_ output: Output) -> Publishers.Optional<Bool, Failure>{
        return Publishers.Optional(self.result.map({ $0 == output}))
        
    }
    
    public func removeDuplicates() -> Publishers.Optional<Output, Failure>{
        return self
    }
}

extension Publishers.Optional where Output : Comparable {
    
    public func min() -> Publishers.Optional<Output, Failure>{
        return self
    }
    
    public func max() -> Publishers.Optional<Output, Failure>{
        return self
    }
}

extension Publishers.Optional {
    
    
    public func allSatisfy(_ predicate: (Output) -> Bool) -> Publishers.Optional<Bool, Failure>{
        return self.map(predicate)
    }
    
    public func tryAllSatisfy(_ predicate: (Output) throws -> Bool) -> Publishers.Optional<Bool, Error> {
        return self.tryMap( predicate)
    }
    
    public func collect() -> Publishers.Optional<[Output], Failure> {
        return self.map({[$0]})
    }
    
    public func compactMap<T>(_ transform: (Output) -> T?) -> Publishers.Optional<T, Failure> {
        return Publishers.Optional(self.result.map({ (output) in
            guard let output = output else {
                return nil
            }
            return transform(output)
        }))
    }
    
    public func tryCompactMap<T>(_ transform: (Output) throws -> T?) -> Publishers.Optional<T, Error>{
        switch self.result {
        case .failure(let error):
            return Publishers.Optional(error)
        case .success(let value):
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
    
    public func min(by areInIncreasingOrder: (Output, Output) -> Bool) -> Publishers.Optional<Output, Failure> {
        return self
    }
    
    public func tryMin(by areInIncreasingOrder: (Output, Output) throws -> Bool) -> Publishers.Optional<Output, Failure> {
        return self
    }
    
    public func max(by areInIncreasingOrder: (Output, Output) -> Bool) -> Publishers.Optional<Output, Failure> {
        return self
    }
    
    public func tryMax(by areInIncreasingOrder: (Output, Output) throws -> Bool) -> Publishers.Optional<Output, Failure> {
        return self
    }
    
    public func contains(where predicate: (Output) -> Bool) -> Publishers.Optional<Bool, Failure> {
        return self.map(predicate)
    }
    
    public func tryContains(where predicate: (Output) throws -> Bool) -> Publishers.Optional<Bool, Error>{
        return self.tryMap( predicate)
    }
    
    public func count() -> Publishers.Optional<Int, Failure>{
        return Publishers.Optional(self.result.map({ $0 == nil ? 0 : 1}))
    }
    
    public func dropFirst(_ count: Int = 1) -> Publishers.Optional<Output, Failure> {
        if count <= 0 {
            return self
        }
        return self.compactMap( { _ in nil  })
    }
    
    public func drop(while predicate: (Output) -> Bool) -> Publishers.Optional<Output, Failure> {
        return self.filter({!predicate($0)})
    }
    
    public func tryDrop(while predicate: (Output) throws -> Bool) -> Publishers.Optional<Output, Error> {
        return self.tryFilter( {try !predicate($0)})
    }
    
    public func first() -> Publishers.Optional<Output, Failure> {
        return self
    }
    
    public func first(where predicate: (Output) -> Bool) -> Publishers.Optional<Output, Failure> {
        return self.filter(predicate)
    }
    
    public func tryFirst(where predicate: (Output) throws -> Bool) -> Publishers.Optional<Output, Error>{
        return self.tryFilter(predicate)
    }
    
    public func last() -> Publishers.Optional<Output, Failure> {
        return self
    }
    
    public func last(where predicate: (Output) -> Bool) -> Publishers.Optional<Output, Failure>{
        return self.first(where: predicate)
    }
    
    public func tryLast(where predicate: (Output) throws -> Bool) -> Publishers.Optional<Output, Error>{
        return self.tryFirst(where: predicate)
    }
    
    public func filter(_ isIncluded: (Output) -> Bool) -> Publishers.Optional<Output, Failure>{
        return self.compactMap({ value in
            return isIncluded(value) ?  value : nil
        })
    }
    
    public func tryFilter(_ isIncluded: (Output) throws -> Bool) -> Publishers.Optional<Output, Error>{
        return self.tryCompactMap( { value in
            return try isIncluded(value) ? value : nil
        })
    }
    
    public func ignoreOutput() -> Publishers.Empty<Output, Failure>{
        return Publishers.Empty()
    }
    
    public func map<T>(_ transform: (Output) -> T) -> Publishers.Optional<T, Failure>{
        return self.compactMap(transform)
    }
    
    public func tryMap<T>(_ transform: (Output) throws -> T) -> Publishers.Optional<T, Error>{
        return self.tryCompactMap(transform)
    }
    
    public func mapError<E>(_ transform: (Failure) -> E) -> Publishers.Optional<Output, E> where E : Error {
        return Publishers.Optional(self.result.mapError(transform))
    }
    
    public func output(at index: Int) -> Publishers.Optional<Output, Failure> {
        return self.output(in: index...index)
    }
    
    public func output<R>(in range: R) -> Publishers.Optional<Output, Failure> where R : RangeExpression, R.Bound == Int {
        return range.contains(0) ? self : self.dropFirst()
    }
    
    public func prefix(_ maxLength: Int) -> Publishers.Optional<Output, Failure> {
        return maxLength > 0 ? self : self.dropFirst()
    }
    
    public func prefix(while predicate: (Output) -> Bool) -> Publishers.Optional<Output, Failure> {
        return self.filter(predicate)
    }
    
    public func tryPrefix(while predicate: (Output) throws -> Bool) -> Publishers.Optional<Output, Error>{
        return self.tryFilter(predicate)
    }
    
    public func reduce<T>(_ initialResult: T, _ nextPartialResult: (T, Output) -> T) -> Publishers.Optional<T, Failure> {
        return self.map({nextPartialResult(initialResult, $0)})
    }
    
    public func tryReduce<T>(_ initialResult: T, _ nextPartialResult: (T, Output) throws -> T) -> Publishers.Optional<T, Error> {
        return self.tryMap({try nextPartialResult(initialResult, $0)})
    }
    
    public func removeDuplicates(by predicate: (Output, Output) -> Bool) -> Publishers.Optional<Output, Failure> {
        return self
    }
    
    public func tryRemoveDuplicates(by predicate: (Output, Output) throws -> Bool) -> Publishers.Optional<Output, Error> {
        return Publishers.Optional(result.mapError({$0}))
    }
    
    public func replaceError(with output: Output) -> Publishers.Optional<Output, Never> {
        switch self.result {
        case .success(let value):
            return Publishers.Optional(value)
        case .failure(_):
            return Publishers.Optional(output)
        }
    }
    
    public func replaceEmpty(with output: Output) -> Publishers.Optional<Output, Failure> {
        switch self.result {
        case .success(let value):
            return Publishers.Optional(value ?? output)
        case .failure(_):
            return self
        }
    }
    
    public func retry(_ times: Int) -> Publishers.Optional<Output, Failure> {
        return self
    }
    
    public func retry() -> Publishers.Optional<Output, Failure> {
        return self
    }
    
    public func scan<T>(_ initialResult: T, _ nextPartialResult: (T, Output) -> T) -> Publishers.Optional<T, Failure> {
        return self.reduce(initialResult, nextPartialResult)
    }
    
    public func tryScan<T>(_ initialResult: T, _ nextPartialResult: (T, Output) throws -> T) -> Publishers.Optional<T, Error> {
        return self.tryReduce(initialResult, nextPartialResult)
    }
}

extension Publishers.Optional where Failure == Never {
    
    public func setFailureType<E>(to failureType: E.Type) -> Publishers.Optional<Output, E> where E : Error{
        return Publishers.Optional(try! self.result.get())
    }
}
