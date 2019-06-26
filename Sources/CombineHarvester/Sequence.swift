extension Publishers {
    /// A publisher that publishes a given sequence of elements.
    ///
    /// When the publisher exhausts the elements in the sequence, the next request causes the publisher to finish.
    public struct Sequence<Elements, Failure>: Publisher where Elements: Swift.Sequence, Failure: Error {
        public typealias Output = Elements.Element

        /// The sequence of elements to publish.
        public let sequence: Elements

        /// Creates a publisher for a sequence of elements.
        ///
        /// - Parameter sequence: The sequence of elements to publish.
        public init(sequence: Elements) {
            self.sequence = sequence
        }

        public func receive<S>(subscriber: S) where Failure == S.Failure, S: Subscriber, Elements.Element == S.Input {
            let sequence = self.sequence
                .lazy
                .map { Result<Output, Failure>.success($0) }
            let subscription = IteratingSubscription(iterator: sequence.makeIterator(), subscriber: subscriber)
            subscriber.receive(subscription: subscription)
        }
    }
}

extension Sequence {
    public func publisher() -> Publishers.Sequence<Self, Never> {
        return Publishers.Sequence(sequence: self)
    }
}

extension Publishers.Sequence {
    public func allSatisfy(_ predicate: (Output) -> Bool) -> Publishers.Once<Bool, Failure> {
        return Publishers.Once(self.sequence.allSatisfy(predicate))
    }

    public func tryAllSatisfy(_ predicate: (Output) throws -> Bool) -> Publishers.Once<Bool, Error> {
        do {
            return Publishers.Once(try self.sequence.allSatisfy(predicate))
        } catch {
            return Publishers.Once(error)
        }
    }

    public func collect() -> Publishers.Once<[Output], Failure> {
        return Publishers.Once(Array(self.sequence))
    }

    public func compactMap<T>(_ transform: (Output) -> T?) -> Publishers.Sequence<[T], Failure> {
        let transformed = self.sequence.compactMap(transform)
        return Publishers.Sequence(sequence: transformed)
    }

    // swiftformat:disable:next typeSugar
    public func min(by areInIncreasingOrder: (Output, Output) -> Bool) -> Publishers.Optional<Output, Failure> {
        // swiftformat:disable:next typeSugar
        return Publishers.Optional(self.sequence.min(by: areInIncreasingOrder))
    }

    // swiftformat:disable:next typeSugar
    public func tryMin(by areInIncreasingOrder: (Output, Output) throws -> Bool) -> Publishers.Optional<Output, Error> {
        do {
            // swiftformat:disable:next typeSugar
            return Publishers.Optional(try self.sequence.min(by: areInIncreasingOrder))
        } catch {
            // swiftformat:disable:next typeSugar
            return Publishers.Optional(error)
        }
    }

    // swiftformat:disable:next typeSugar
    public func max(by areInIncreasingOrder: (Output, Output) -> Bool) -> Publishers.Optional<Output, Failure> {
        // swiftformat:disable:next typeSugar
        return Publishers.Optional(self.sequence.max(by: areInIncreasingOrder))
    }

    // swiftformat:disable:next typeSugar
    public func tryMax(by areInIncreasingOrder: (Output, Output) throws -> Bool) -> Publishers.Optional<Output, Error> {
        do {
            // swiftformat:disable:next typeSugar
            return Publishers.Optional(try self.sequence.max(by: areInIncreasingOrder))
        } catch {
            // swiftformat:disable:next typeSugar
            return Publishers.Optional(error)
        }
    }

    public func contains(where predicate: (Output) -> Bool) -> Publishers.Once<Bool, Failure> {
        return Publishers.Once(self.sequence.contains(where: predicate))
    }

    public func tryContains(where predicate: (Output) throws -> Bool) -> Publishers.Once<Bool, Error> {
        do {
            return Publishers.Once(try self.sequence.contains(where: predicate))
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

    // swiftformat:disable:next typeSugar
    public func first(where predicate: (Output) -> Bool) -> Publishers.Optional<Output, Failure> {
        // swiftformat:disable:next typeSugar
        return Publishers.Optional(self.sequence.first(where: predicate))
    }

    // swiftformat:disable:next typeSugar
    public func tryFirst(where predicate: (Output) throws -> Bool) -> Publishers.Optional<Output, Error> {
        do {
            // swiftformat:disable:next typeSugar
            return Publishers.Optional(try self.sequence.first(where: predicate))
        } catch {
            // swiftformat:disable:next typeSugar
            return Publishers.Optional(error)
        }
    }

    public func filter(_ isIncluded: (Output) -> Bool) -> Publishers.Sequence<[Output], Failure> {
        return Publishers.Sequence(sequence: self.sequence.filter(isIncluded))
    }

    public func ignoreOutput() -> Publishers.Empty<Output, Failure> {
        return Publishers.Empty()
    }

    public func map<T>(_ transform: (Elements.Element) -> T) -> Publishers.Sequence<[T], Failure> {
        return Publishers.Sequence(sequence: self.sequence.map(transform))
    }

    public func prefix(_ maxLength: Int) -> Publishers.Sequence<PrefixSequence<Elements>, Failure> {
        return Publishers.Sequence(sequence: self.sequence.prefix(maxLength))
    }

    public func prefix(while predicate: (Elements.Element) -> Bool) -> Publishers.Sequence<[Elements.Element], Failure> {
        return Publishers.Sequence(sequence: self.sequence.prefix(while: predicate))
    }

    public func reduce<T>(_ initialResult: T, _ nextPartialResult: @escaping (T, Output) -> T) -> Publishers.Once<T, Failure> {
        return Publishers.Once(self.sequence.reduce(initialResult, nextPartialResult))
    }

    public func tryReduce<T>(_ initialResult: T, _ nextPartialResult: @escaping (T, Output) throws -> T) -> Publishers.Once<T, Error> {
        do {
            return Publishers.Once(try self.sequence.reduce(initialResult, nextPartialResult))
        } catch {
            return Publishers.Once(error)
        }
    }

    public func replaceNil<T>(with output: T) -> Publishers.Sequence<[T], Failure> where Elements.Element == T? {
        return self.map { $0 ?? output }
    }

    public func scan<T>(_ initialResult: T, _ nextPartialResult: @escaping (T, Output) -> T) -> Publishers.Sequence<[T], Failure> {
        var state = initialResult
        return self.map { value in
            state = nextPartialResult(state, value)
            return state
        }
    }

    public func setFailureType<E>(to _: E.Type) -> Publishers.Sequence<Elements, E> where E: Error {
        return Publishers.Sequence(sequence: self.sequence)
    }
}

extension Publishers.Sequence where Elements.Element: Equatable {
    public func removeDuplicates() -> Publishers.Sequence<[Output], Failure> {
        var previous: Elements.Element?
        return self.filter { element in
            let isDuplicate = previous == element
            previous = element
            return !isDuplicate
        }
    }

    public func contains(_ output: Elements.Element) -> Publishers.Once<Bool, Failure> {
        return Publishers.Once(self.sequence.contains(output))
    }
}

extension Publishers.Sequence where Elements.Element: Comparable {
    // swiftformat:disable:next typeSugar
    public func min() -> Publishers.Optional<Elements.Element, Failure> {
        // swiftformat:disable:next typeSugar
        return Publishers.Optional(self.sequence.min())
    }

    // swiftformat:disable:next typeSugar
    public func max() -> Publishers.Optional<Elements.Element, Failure> {
        // swiftformat:disable:next typeSugar
        return Publishers.Optional(self.sequence.max())
    }
}

extension Publishers.Sequence where Elements: Collection {
    // swiftformat:disable:next typeSugar
    public func first() -> Publishers.Optional<Elements.Element, Failure> {
        // swiftformat:disable:next typeSugar
        return Publishers.Optional(self.sequence.first)
    }
}

extension Publishers.Sequence where Elements: Collection {
    public func count() -> Publishers.Once<Int, Failure> {
        return Publishers.Once(self.sequence.count)
    }
}

extension Publishers.Sequence where Elements: Collection {
    private var range: Range<Elements.Index> {
        return self.sequence.startIndex..<self.sequence.endIndex
    }

    // swiftformat:disable:next typeSugar
    public func output(at index: Elements.Index) -> Publishers.Optional<Output, Failure> {
        guard self.range.contains(index) else {
            // swiftformat:disable:next typeSugar
            return Publishers.Optional(nil)
        }
        let value = self.sequence[index]
        // swiftformat:disable:next typeSugar
        return Publishers.Optional(value)
    }

    public func output(in range: Range<Elements.Index>) -> Publishers.Sequence<[Output], Failure> {
        let clamped = range.clamped(to: self.range)
        let sequence = Array(self.sequence[clamped])
        return Publishers.Sequence(sequence: sequence)
    }
}

extension Publishers.Sequence where Elements: BidirectionalCollection {
    // swiftformat:disable:next typeSugar
    public func last() -> Publishers.Optional<Output, Failure> {
        // swiftformat:disable:next typeSugar
        return Publishers.Optional(self.sequence.last)
    }

    // swiftformat:disable:next typeSugar
    public func last(where predicate: (Output) -> Bool) -> Publishers.Optional<Output, Failure> {
        // swiftformat:disable:next typeSugar
        return Publishers.Optional(self.sequence.last(where: predicate))
    }

    // swiftformat:disable:next typeSugar
    public func tryLast(where predicate: (Output) throws -> Bool) -> Publishers.Optional<Output, Error> {
        do {
            // swiftformat:disable:next typeSugar
            return Publishers.Optional(try self.sequence.last(where: predicate))
        } catch {
            // swiftformat:disable:next typeSugar
            return Publishers.Optional(error)
        }
    }
}

extension Publishers.Sequence where Elements: RandomAccessCollection {
    // swiftformat:disable:next typeSugar
    public func output(at index: Elements.Index) -> Publishers.Optional<Output, Failure> {
        guard self.range.contains(index) else {
            // swiftformat:disable:next typeSugar
            return Publishers.Optional(nil)
        }
        let value = self.sequence[index]
        // swiftformat:disable:next typeSugar
        return Publishers.Optional(value)
    }

    public func output(in range: Range<Elements.Index>) -> Publishers.Sequence<[Output], Failure> {
        let clamped = range.clamped(to: self.range)
        let sequence = Array(self.sequence[clamped])
        return Publishers.Sequence(sequence: sequence)
    }
}

extension Publishers.Sequence where Elements: RandomAccessCollection {
    // swiftformat:disable:next typeSugar
    public func count() -> Publishers.Optional<Int, Failure> {
        // swiftformat:disable:next typeSugar
        return Publishers.Optional(self.sequence.count)
    }
}

extension Publishers.Sequence: Equatable where Elements: Equatable {
}

extension Publishers.Sequence where Elements: RangeReplaceableCollection {
    public func prepend(_ elements: Output...) -> Publishers.Sequence<Elements, Failure> {
        return Publishers.Sequence(sequence: elements + sequence)
    }

    public func prepend<S>(_ elements: S) -> Publishers.Sequence<Elements, Failure> where S: Swift.Sequence, Elements.Element == S.Element {
        return Publishers.Sequence(sequence: elements + sequence)
    }

    public func prepend(_ publisher: Publishers.Sequence<Elements, Failure>) -> Publishers.Sequence<Elements, Failure> {
        return Publishers.Sequence(sequence: publisher.sequence + self.sequence)
    }

    public func append(_ elements: Output...) -> Publishers.Sequence<Elements, Failure> {
        return Publishers.Sequence(sequence: sequence + elements)
    }

    public func append<S>(_ elements: S) -> Publishers.Sequence<Elements, Failure> where S: Sequence, Elements.Element == S.Element {
        return Publishers.Sequence(sequence: sequence + elements)
    }

    public func append(_ publisher: Publishers.Sequence<Elements, Failure>) -> Publishers.Sequence<Elements, Failure> {
        return Publishers.Sequence(sequence: sequence + publisher.sequence)
    }
}
