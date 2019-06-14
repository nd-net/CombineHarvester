import RxSwift
extension Publishers {
    
    
    /// A publisher that publishes a given sequence of elements.
    ///
    /// When the publisher exhausts the elements in the sequence, the next request causes the publisher to finish.
    public struct Sequence<Elements, Failure> : Publisher where Elements : Swift.Sequence, Failure : Error {
        
        /// The kind of values published by this publisher.
        public typealias Output = Elements.Element
        
        /// The sequence of elements to publish.
        public let sequence: Elements
        
        /// Creates a publisher for a sequence of elements.
        ///
        /// - Parameter sequence: The sequence of elements to publish.
        public init(sequence: Elements){
        self.sequence = sequence
        }
        
        /// This function is called to attach the specified `Subscriber` to this `Publisher` by `subscribe(_:)`
        ///
        /// - SeeAlso: `subscribe(_:)`
        /// - Parameters:
        ///     - subscriber: The subscriber to attach to this `Publisher`.
        ///                   once attached it can begin to receive values.
        public func receive<S>(subscriber: S) where Failure == S.Failure, S : Subscriber, Elements.Element == S.Input{
            notImplemented()
        }
    }
}


extension Sequence {
    public func publisher() -> Publishers.Sequence<Self, Never> {
        return Publishers.Sequence(sequence: self)
    }
}

extension Publishers.Sequence {
    
    public func allSatisfy(_ predicate: (Publishers.Sequence<Elements, Failure>.Output) -> Bool) -> Publishers.Once<Bool, Failure> {
        return Publishers.Once(self.sequence.allSatisfy(predicate))
    }
    
    public func tryAllSatisfy(_ predicate: (Publishers.Sequence<Elements, Failure>.Output) throws -> Bool) -> Publishers.Once<Bool, Error> {
        do {
        return Publishers.Once(try self.sequence.allSatisfy(predicate))
        } catch {
            return Publishers.Once(error)
        }
    }
    
    public func collect() -> Publishers.Once<[Publishers.Sequence<Elements, Failure>.Output], Failure> {
        return Publishers.Once(Array(self.sequence))
    }
    
    public func compactMap<T>(_ transform: (Publishers.Sequence<Elements, Failure>.Output) -> T?) -> Publishers.Sequence<[T], Failure> {
        let transformed = self.sequence.compactMap(transform)
        return Publishers.Sequence(sequence: transformed)
    }
    
    public func min(by areInIncreasingOrder: (Publishers.Sequence<Elements, Failure>.Output, Publishers.Sequence<Elements, Failure>.Output) -> Bool) -> Publishers.Optional<Publishers.Sequence<Elements, Failure>.Output, Failure> {
        return Publishers.Optional(self.sequence.min(by: areInIncreasingOrder))
    }
    
    public func tryMin(by areInIncreasingOrder: (Publishers.Sequence<Elements, Failure>.Output, Publishers.Sequence<Elements, Failure>.Output) throws -> Bool) -> Publishers.Optional<Publishers.Sequence<Elements, Failure>.Output, Error> {
        do {
        return Publishers.Optional(try self.sequence.min(by: areInIncreasingOrder))
        } catch {
            return Publishers.Optional(error)
        }
    }
    
    public func max(by areInIncreasingOrder: (Publishers.Sequence<Elements, Failure>.Output, Publishers.Sequence<Elements, Failure>.Output) -> Bool) -> Publishers.Optional<Publishers.Sequence<Elements, Failure>.Output, Failure> {
        return Publishers.Optional(self.sequence.max(by: areInIncreasingOrder))
    }
    
    public func tryMax(by areInIncreasingOrder: (Publishers.Sequence<Elements, Failure>.Output, Publishers.Sequence<Elements, Failure>.Output) throws -> Bool) -> Publishers.Optional<Publishers.Sequence<Elements, Failure>.Output, Error> {
        do {
            return Publishers.Optional(try self.sequence.max(by: areInIncreasingOrder))
        } catch {
            return Publishers.Optional(error)
        }
    }
    
    public func contains(where predicate: (Publishers.Sequence<Elements, Failure>.Output) -> Bool) -> Publishers.Once<Bool, Failure> {
        return Publishers.Once(self.sequence.contains(where:predicate))
    }
    
    public func tryContains(where predicate: (Publishers.Sequence<Elements, Failure>.Output) throws -> Bool) -> Publishers.Once<Bool, Error> {
        do {
        return Publishers.Once(try self.sequence.contains(where:predicate))
    } catch {
    return Publishers.Once(error)
    }
    }
    
    public func drop(while predicate: (Elements.Element) -> Bool) -> Publishers.Sequence<DropWhileSequence<Elements>, Failure> {
        return Publishers.Sequence(sequence: self.sequence.drop(while: predicate))
    }
    
    public func dropFirst(_ count: Int = 1) -> Publishers.Sequence<DropFirstSequence<Elements>, Failure> {
        return Publishers.Sequence(sequence: self.sequence.dropFirst(count))
    }
    
    public func first(where predicate: (Publishers.Sequence<Elements, Failure>.Output) -> Bool) -> Publishers.Optional<Publishers.Sequence<Elements, Failure>.Output, Failure> {
        return Publishers.Optional(self.sequence.first(where: predicate))
    }
    
    public func tryFirst(where predicate: (Publishers.Sequence<Elements, Failure>.Output) throws -> Bool) -> Publishers.Optional<Publishers.Sequence<Elements, Failure>.Output, Error> {
        do {
        return Publishers.Optional(try self.sequence.first(where: predicate))
        } catch {
            return Publishers.Optional(error)
        }
    }
    
    public func filter(_ isIncluded: (Publishers.Sequence<Elements, Failure>.Output) -> Bool) -> Publishers.Sequence<[Publishers.Sequence<Elements, Failure>.Output], Failure> {
        return Publishers.Sequence(sequence: self.sequence.filter(isIncluded))
    }
    
    public func ignoreOutput() -> Publishers.Empty<Publishers.Sequence<Elements, Failure>.Output, Failure> {
        return Publishers.Empty()
    }
    
    public func map<T>(_ transform: (Elements.Element) -> T) -> Publishers.Sequence<[T], Failure> {
        return Publishers.Sequence(sequence: self.sequence.map(transform))
    }
    
    public func prefix(_ maxLength: Int) -> Publishers.Sequence<PrefixSequence<Elements>, Failure> {
        return Publishers.Sequence(sequence: self.sequence.prefix(maxLength))
    }
    
    public func prefix(while predicate: (Elements.Element) -> Bool) -> Publishers.Sequence<[Elements.Element], Failure> {
        return Publishers.Sequence(sequence: self.sequence.prefix(while:predicate))
    }
    
    public func reduce<T>(_ initialResult: T, _ nextPartialResult: @escaping (T, Publishers.Sequence<Elements, Failure>.Output) -> T) -> Publishers.Once<T, Failure> {
        return Publishers.Once(self.sequence.reduce(initialResult, nextPartialResult))
    }
    
    public func tryReduce<T>(_ initialResult: T, _ nextPartialResult: @escaping (T, Publishers.Sequence<Elements, Failure>.Output) throws -> T) -> Publishers.Once<T, Error> {
        do {
            return Publishers.Once(try self.sequence.reduce(initialResult, nextPartialResult))
        } catch {
            return Publishers.Once(error)
        }
    }
    
    public func replaceNil<T>(with output: T) -> Publishers.Sequence<[Publishers.Sequence<Elements, Failure>.Output], Failure> where Elements.Element == T? {
        return self.map({ $0 ?? output })
    }
    
    public func scan<T>(_ initialResult: T, _ nextPartialResult: @escaping (T, Publishers.Sequence<Elements, Failure>.Output) -> T) -> Publishers.Sequence<[T], Failure> {
        var state = initialResult
        return self.map { value in
            state = nextPartialResult(state, value)
            return state
        }
    }
    
    public func setFailureType<E>(to error: E.Type) -> Publishers.Sequence<Elements, E> where E : Error {
        return Publishers.Sequence(sequence: self.sequence)
    }
}


extension Publishers.Sequence where Elements.Element: Equatable {
    public func removeDuplicates() -> Publishers.Sequence<[Publishers.Sequence<Elements, Failure>.Output], Failure> {
        var previous: Elements.Element? = nil
        return self.filter({ element in
            let isDuplicate = previous == element
            previous = element
            return !isDuplicate
        })
    }
    
    public func contains(_ output: Elements.Element) -> Publishers.Once<Bool, Failure> {
        return Publishers.Once(self.sequence.contains(output))
    }
}

extension Publishers.Sequence where Elements.Element: Comparable {
    public func min() -> Publishers.Optional<Elements.Element, Failure> {
        return Publishers.Optional(self.sequence.min())
    }
    
    public func max() -> Publishers.Optional<Elements.Element, Failure> {
        return Publishers.Optional(self.sequence.max())
    }
}

extension Publishers.Sequence where Elements: Collection {
    public func first() -> Publishers.Optional<Elements.Element, Failure> {
        return Publishers.Optional(self.sequence.first)
    }
}

extension Publishers.Sequence where Elements: Collection {
    public func count() -> Publishers.Once<Int, Failure> {
        return Publishers.Once(self.sequence.count)
    }
}

extension Publishers.Sequence where Elements : Collection {
    
    public func output(at index: Elements.Index) -> Publishers.Optional<Publishers.Sequence<Elements, Failure>.Output, Failure> {
        guard index >= sequence.startIndex && index < sequence.endIndex else {
            return Publishers.Optional(nil)
        }
        let value = self.sequence[index]
        return Publishers.Optional(value)
    }
    
    public func output(in range: Range<Elements.Index>) -> Publishers.Sequence<[Publishers.Sequence<Elements, Failure>.Output], Failure> {
        let sequence = Array(self.sequence[range])
        return Publishers.Sequence(sequence: sequence)
    }
}

extension Publishers.Sequence where Elements : BidirectionalCollection {
    
    public func last() -> Publishers.Optional<Publishers.Sequence<Elements, Failure>.Output, Failure>{
        return Publishers.Optional(self.sequence.last)
    }
    
    public func last(where predicate: (Publishers.Sequence<Elements, Failure>.Output) -> Bool) -> Publishers.Optional<Publishers.Sequence<Elements, Failure>.Output, Failure> {
        return Publishers.Optional(self.sequence.last(where: predicate))
    }
    
    public func tryLast(where predicate: (Publishers.Sequence<Elements, Failure>.Output) throws -> Bool) -> Publishers.Optional<Publishers.Sequence<Elements, Failure>.Output, Error> {
        do {
            return Publishers.Optional(try self.sequence.last(where: predicate))
        } catch {
            return Publishers.Optional(error)
        }
    }
}


extension Publishers.Sequence where Elements : RandomAccessCollection {
    
    public func output(at index: Elements.Index) -> Publishers.Optional<Publishers.Sequence<Elements, Failure>.Output, Failure> {
        guard index >= sequence.startIndex && index < sequence.endIndex else {
            return Publishers.Optional(nil)
        }
        let value = self.sequence[index]
        return Publishers.Optional(value)
    }
    
    public func output(in range: Range<Elements.Index>) -> Publishers.Sequence<[Publishers.Sequence<Elements, Failure>.Output], Failure> {
        let sequence = Array(self.sequence[range])
        return Publishers.Sequence(sequence: sequence)
    }
}

extension Publishers.Sequence where Elements : RandomAccessCollection {
    
    public func count() -> Publishers.Optional<Int, Failure> {
        return Publishers.Optional(self.sequence.count)
    }
}


extension Publishers.Sequence: Equatable where Elements: Equatable {
    /// Returns a Boolean value indicating whether two values are equal.
    ///
    /// Equality is the inverse of inequality. For any values `a` and `b`,
    /// `a == b` implies that `a != b` is `false`.
    ///
    /// - Parameters:
    ///   - lhs: A value to compare.
    ///   - rhs: Another value to compare.
    public static func == (lhs: Publishers.Sequence<Elements, Failure>, rhs: Publishers.Sequence<Elements, Failure>) -> Bool {
        return lhs.sequence == rhs.sequence
    }
}


extension Publishers.Sequence where Elements : RangeReplaceableCollection {
    
    public func prepend(_ elements: Publishers.Sequence<Elements, Failure>.Output...) -> Publishers.Sequence<Elements, Failure> {
        return Publishers.Sequence(sequence: elements + sequence)
    }
    
    public func prepend<S>(_ elements: S) -> Publishers.Sequence<Elements, Failure> where S : Swift.Sequence, Elements.Element == S.Element {
        return Publishers.Sequence(sequence: elements + sequence)
    }
    
    public func prepend(_ publisher: Publishers.Sequence<Elements, Failure>) -> Publishers.Sequence<Elements, Failure> {
        return Publishers.Sequence(sequence: publisher.sequence + self.sequence)
    }
    
    public func append(_ elements: Publishers.Sequence<Elements, Failure>.Output...) -> Publishers.Sequence<Elements, Failure> {
        return Publishers.Sequence(sequence:  sequence+elements)
    }
    
    public func append<S>(_ elements: S) -> Publishers.Sequence<Elements, Failure> where S : Sequence, Elements.Element == S.Element{
        return Publishers.Sequence(sequence:  sequence+elements)

    }
    
    public func append(_ publisher: Publishers.Sequence<Elements, Failure>) -> Publishers.Sequence<Elements, Failure> {
        return Publishers.Sequence(sequence:  sequence+publisher.sequence)
    }
}
