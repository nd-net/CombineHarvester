extension Publishers {
    /// A publisher that omits a specified number of elements before republishing later elements.
    public struct Drop<Upstream: Publisher>: Publisher {
        public typealias Output = Upstream.Output
        public typealias Failure = Upstream.Failure

        /// The publisher from which this publisher receives elements.
        public let upstream: Upstream

        /// The number of elements to drop.
        public let count: Int

        public init(upstream: Upstream, count: Int) {
            self.upstream = upstream
            self.count = count
        }

        public func receive<S: Subscriber>(subscriber: S) where Upstream.Failure == S.Failure, Upstream.Output == S.Input {
            guard self.count > 0 else {
                self.upstream.subscribe(subscriber)
                return
            }
            self.upstream.output(in: self.count...)
                .subscribe(subscriber)
        }
    }
}

extension Publishers.Drop: Equatable where Upstream: Equatable {
}

extension Publishers {
    /// A publisher that omits elements from an upstream publisher until a given closure returns false.
    public struct DropWhile<Upstream: Publisher>: Publisher {
        public typealias Output = Upstream.Output
        public typealias Failure = Upstream.Failure

        /// The publisher from which this publisher receives elements.
        public let upstream: Upstream

        /// The closure that indicates whether to drop the element.
        public let predicate: (Upstream.Output) -> Bool

        public func receive<S: Subscriber>(subscriber: S) where Upstream.Failure == S.Failure, Upstream.Output == S.Input {
            var finished = false

            upstream.compactMap { value in
                if finished {
                    return value
                }
                finished = !self.predicate(value)
                return finished ? value : nil
            }.subscribe(subscriber)
        }
    }

    /// A publisher that omits elements from an upstream publisher until a given error-throwing closure returns false.
    public struct TryDropWhile<Upstream: Publisher>: Publisher {
        public typealias Output = Upstream.Output
        public typealias Failure = Error

        /// The publisher from which this publisher receives elements.
        public let upstream: Upstream

        /// The error-throwing closure that indicates whether to drop the element.
        public let predicate: (Upstream.Output) throws -> Bool

        public func receive<S: Subscriber>(subscriber: S) where Upstream.Output == S.Input, S.Failure == Publishers.TryDropWhile<Upstream>.Failure {
            var finished = false

            upstream.tryCompactMap { value in
                if finished {
                    return value
                }
                finished = try !self.predicate(value)
                return finished ? value : nil
            }.subscribe(subscriber)
        }
    }
}

extension Publisher {
    /// Omits the specified number of elements before republishing subsequent elements.
    ///
    /// - Parameter count: The number of elements to omit.
    /// - Returns: A publisher that does not republish the first `count` elements.
    public func dropFirst(_ count: Int = 1) -> Publishers.Drop<Self> {
        return Publishers.Drop(upstream: self, count: count)
    }
}

extension Publisher {
    /// Omits elements from the upstream publisher until a given closure returns false, before republishing all remaining elements.
    ///
    /// - Parameter predicate: A closure that takes an element as a parameter and returns a Boolean
    /// value indicating whether to drop the element from the publisher’s output.
    /// - Returns: A publisher that skips over elements until the provided closure returns `false`.
    public func drop(while predicate: @escaping (Self.Output) -> Bool) -> Publishers.DropWhile<Self> {
        return Publishers.DropWhile(upstream: self, predicate: predicate)
    }

    /// Omits elements from the upstream publisher until an error-throwing closure returns false, before republishing all remaining elements.
    ///
    /// If the predicate closure throws, the publisher fails with an error.
    ///
    /// - Parameter predicate: A closure that takes an element as a parameter and returns a Boolean value indicating whether to drop the element from the publisher’s output.
    /// - Returns: A publisher that skips over elements until the provided closure returns `false`, and then republishes all remaining elements. If the predicate closure throws, the publisher fails with an error.
    public func tryDrop(while predicate: @escaping (Self.Output) throws -> Bool) -> Publishers.TryDropWhile<Self> {
        return Publishers.TryDropWhile(upstream: self, predicate: predicate)
    }
}
