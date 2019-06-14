
extension Publishers {
    /// A publisher that receives and combines the latest elements from two publishers.
    public struct CombineLatest<A, B, Output>: Publisher where A: Publisher, B: Publisher, A.Failure == B.Failure {
        /// The kind of errors this publisher might publish.
        ///
        /// Use `Never` if this `Publisher` does not publish errors.
        public typealias Failure = A.Failure
        
        public let a: A
        
        public let b: B
        
        public let transform: (A.Output, B.Output) -> Output
        
        /// This function is called to attach the specified `Subscriber` to this `Publisher` by `subscribe(_:)`
        ///
        /// - SeeAlso: `subscribe(_:)`
        /// - Parameters:
        ///     - subscriber: The subscriber to attach to this `Publisher`.
        ///                   once attached it can begin to receive values.
        public func receive<S>(subscriber: S) where Output == S.Input, S: Subscriber, B.Failure == S.Failure { notImplemented() }
    }
    
    /// A publisher that receives and combines the latest elements from three publishers.
    public struct CombineLatest3<A, B, C, Output>: Publisher where A: Publisher, B: Publisher, C: Publisher, A.Failure == B.Failure, B.Failure == C.Failure {
        /// The kind of errors this publisher might publish.
        ///
        /// Use `Never` if this `Publisher` does not publish errors.
        public typealias Failure = A.Failure
        
        public let a: A
        
        public let b: B
        
        public let c: C
        
        public let transform: (A.Output, B.Output, C.Output) -> Output
        
        /// This function is called to attach the specified `Subscriber` to this `Publisher` by `subscribe(_:)`
        ///
        /// - SeeAlso: `subscribe(_:)`
        /// - Parameters:
        ///     - subscriber: The subscriber to attach to this `Publisher`.
        ///                   once attached it can begin to receive values.
        public func receive<S>(subscriber: S) where Output == S.Input, S: Subscriber, C.Failure == S.Failure { notImplemented() }
    }
    
    /// A publisher that receives and combines the latest elements from four publishers.
    public struct CombineLatest4<A, B, C, D, Output>: Publisher where A: Publisher, B: Publisher, C: Publisher, D: Publisher, A.Failure == B.Failure, B.Failure == C.Failure, C.Failure == D.Failure {
        /// The kind of errors this publisher might publish.
        ///
        /// Use `Never` if this `Publisher` does not publish errors.
        public typealias Failure = A.Failure
        
        public let a: A
        
        public let b: B
        
        public let c: C
        
        public let d: D
        
        public let transform: (A.Output, B.Output, C.Output, D.Output) -> Output
        
        /// This function is called to attach the specified `Subscriber` to this `Publisher` by `subscribe(_:)`
        ///
        /// - SeeAlso: `subscribe(_:)`
        /// - Parameters:
        ///     - subscriber: The subscriber to attach to this `Publisher`.
        ///                   once attached it can begin to receive values.
        public func receive<S>(subscriber: S) where Output == S.Input, S: Subscriber, D.Failure == S.Failure { notImplemented() }
    }
    
    /// A publisher that receives and combines the latest elements from two publishers, using a throwing closure.
    public struct TryCombineLatest<A, B, Output>: Publisher where A: Publisher, B: Publisher, A.Failure == Error, B.Failure == Error {
        /// The kind of errors this publisher might publish.
        ///
        /// Use `Never` if this `Publisher` does not publish errors.
        public typealias Failure = Error
        
        public let a: A
        
        public let b: B
        
        public let transform: (A.Output, B.Output) throws -> Output
        
        /// This function is called to attach the specified `Subscriber` to this `Publisher` by `subscribe(_:)`
        ///
        /// - SeeAlso: `subscribe(_:)`
        /// - Parameters:
        ///     - subscriber: The subscriber to attach to this `Publisher`.
        ///                   once attached it can begin to receive values.
        public func receive<S>(subscriber: S) where Output == S.Input, S: Subscriber, S.Failure == Publishers.TryCombineLatest<A, B, Output>.Failure { notImplemented() }
    }
    
    /// A publisher that receives and combines the latest elements from three publishers, using a throwing closure.
    public struct TryCombineLatest3<A, B, C, Output>: Publisher where A: Publisher, B: Publisher, C: Publisher, A.Failure == Error, B.Failure == Error, C.Failure == Error {
        /// The kind of errors this publisher might publish.
        ///
        /// Use `Never` if this `Publisher` does not publish errors.
        public typealias Failure = Error
        
        public let a: A
        
        public let b: B
        
        public let c: C
        
        public let transform: (A.Output, B.Output, C.Output) throws -> Output
        
        /// This function is called to attach the specified `Subscriber` to this `Publisher` by `subscribe(_:)`
        ///
        /// - SeeAlso: `subscribe(_:)`
        /// - Parameters:
        ///     - subscriber: The subscriber to attach to this `Publisher`.
        ///                   once attached it can begin to receive values.
        public func receive<S>(subscriber: S) where Output == S.Input, S: Subscriber, S.Failure == Publishers.TryCombineLatest3<A, B, C, Output>.Failure { notImplemented() }
    }
    
    /// A publisher that receives and combines the latest elements from four publishers, using a throwing closure.
    public struct TryCombineLatest4<A, B, C, D, Output>: Publisher where A: Publisher, B: Publisher, C: Publisher, D: Publisher, A.Failure == Error, B.Failure == Error, C.Failure == Error, D.Failure == Error {
        /// The kind of errors this publisher might publish.
        ///
        /// Use `Never` if this `Publisher` does not publish errors.
        public typealias Failure = Error
        
        public let a: A
        
        public let b: B
        
        public let c: C
        
        public let d: D
        
        public let transform: (A.Output, B.Output, C.Output, D.Output) throws -> Output
        
        /// This function is called to attach the specified `Subscriber` to this `Publisher` by `subscribe(_:)`
        ///
        /// - SeeAlso: `subscribe(_:)`
        /// - Parameters:
        ///     - subscriber: The subscriber to attach to this `Publisher`.
        ///                   once attached it can begin to receive values.
        public func receive<S>(subscriber: S) where Output == S.Input, S: Subscriber, S.Failure == Publishers.TryCombineLatest4<A, B, C, D, Output>.Failure { notImplemented() }
    }
}

extension Publisher {
    /// Subscribes to an additional publisher and invokes a closure upon receiving output from either publisher.
    ///
    /// The combined publisher passes through any requests to *all* upstream publishers. However, it still obeys the demand-fulfilling rule of only sending the request amount downstream. If the demand isn’t `.unlimited`, it drops values from upstream publishers. It implements this by using a buffer size of 1 for each upstream, and holds the most recent value in each buffer.
    /// All upstream publishers need to finish for this publisher to finsh. If an upstream publisher never publishes a value, this publisher never finishes.
    /// If any of the combined publishers terminates with a failure, this publisher also fails.
    /// - Parameters:
    ///   - other: Another publisher to combine with this one.
    ///   - transform: A closure that receives the most recent value from each publisher and returns a new value to publish.
    /// - Returns: A publisher that receives and combines elements from this and another publisher.
    public func combineLatest<P, T>(_ other: P, _ transform: @escaping (Self.Output, P.Output) -> T) -> Publishers.CombineLatest<Self, P, T> where P: Publisher, Self.Failure == P.Failure {
        return Publishers.CombineLatest(a: self, b: other,  transform: transform)
    }
    
    /// Subscribes to two additional publishers and invokes a closure upon receiving output from any of the publishers.
    ///
    /// The combined publisher passes through any requests to *all* upstream publishers. However, it still obeys the demand-fulfilling rule of only sending the request amount downstream. If the demand isn’t `.unlimited`, it drops values from upstream publishers. It implements this by using a buffer size of 1 for each upstream, and holds the most recent value in each buffer.
    /// All upstream publishers need to finish for this publisher to finish. If an upstream publisher never publishes a value, this publisher never finishes.
    /// If any of the combined publishers terminates with a failure, this publisher also fails.
    /// - Parameters:
    ///   - publisher1: A second publisher to combine with this one.
    ///   - publisher2: A third publisher to combine with this one.
    ///   - transform: A closure that receives the most recent value from each publisher and returns a new value to publish.
    /// - Returns: A publisher that receives and combines elements from this publisher and two other publishers.
    public func combineLatest<P, Q, T>(_ publisher1: P, _ publisher2: Q, _ transform: @escaping (Self.Output, P.Output, Q.Output) -> T) -> Publishers.CombineLatest3<Self, P, Q, T> where P: Publisher, Q: Publisher, Self.Failure == P.Failure, P.Failure == Q.Failure {
        return Publishers.CombineLatest3(a: self, b: publisher1, c: publisher2, transform: transform)
    }
    
    /// Subscribes to three additional publishers and invokes a closure upon receiving output from any of the publishers.
    ///
    /// The combined publisher passes through any requests to *all* upstream publishers. However, it still obeys the demand-fulfilling rule of only sending the request amount downstream. If the demand isn’t `.unlimited`, it drops values from upstream publishers. It implements this by using a buffer size of 1 for each upstream, and holds the most recent value in each buffer.
    /// All upstream publishers need to finish for this publisher to finish. If an upstream publisher never publishes a value, this publisher never finishes.
    /// If any of the combined publishers terminates with a failure, this publisher also fails.
    /// - Parameters:
    ///   - publisher1: A second publisher to combine with this one.
    ///   - publisher2: A third publisher to combine with this one.
    ///   - publisher3: A fourth publisher to combine with this one.
    ///   - transform: A closure that receives the most recent value from each publisher and returns a new value to publish.
    /// - Returns: A publisher that receives and combines elements from this publisher and three other publishers.
    public func combineLatest<P, Q, R, T>(_ publisher1: P, _ publisher2: Q, _ publisher3: R, _ transform: @escaping (Self.Output, P.Output, Q.Output, R.Output) -> T) -> Publishers.CombineLatest4<Self, P, Q, R, T> where P: Publisher, Q: Publisher, R: Publisher, Self.Failure == P.Failure, P.Failure == Q.Failure, Q.Failure == R.Failure {
        return Publishers.CombineLatest4(a: self, b: publisher1, c: publisher2, d: publisher3, transform: transform)
    }
    
    /// Subscribes to an additional publisher and invokes an error-throwing closure upon receiving output from either publisher.
    ///
    /// The combined publisher passes through any requests to *all* upstream publishers. However, it still obeys the demand-fulfilling rule of only sending the request amount downstream. If the demand isn’t `.unlimited`, it drops values from upstream publishers. It implements this by using a buffer size of 1 for each upstream, and holds the most recent value in each buffer.
    /// If the provided transform throws an error, the publisher fails with the error. `Self.Failure` and `P.Failure` must both be `Swift.Error`.
    /// All upstream publishers need to finish for this publisher to finish. If an upstream publisher never publishes a value, this publisher never finishes.
    /// If any of the combined publishers terminates with a failure, this publisher also fails.
    /// - Parameters:
    ///   - other: Another publisher to combine with this one.
    ///   - transform: A closure that receives the most recent value from each publisher and returns a new value to publish.
    /// - Returns: A publisher that receives and combines elements from this and another publisher.
    public func tryCombineLatest<P, T>(_ other: P, _ transform: @escaping (Self.Output, P.Output) throws -> T) -> Publishers.TryCombineLatest<Self, P, T> where P: Publisher, P.Failure == Error {
        return Publishers.TryCombineLatest(a: self, b: other,  transform: transform)

    }
    
    /// Subscribes to two additional publishers and invokes an error-throwing closure upon receiving output from any of the publishers.
    ///
    /// The combined publisher passes through any requests to *all* upstream publishers. However, it still obeys the demand-fulfilling rule of only sending the request amount downstream. If the demand isn’t `.unlimited`, it drops values from upstream publishers. It implements this by using a buffer size of 1 for each upstream, and holds the most recent value in each buffer.
    /// If the provided transform throws an error, the publisher fails with the error. `Self.Failure`, `P.Failure`, and `Q.Failure` must all be `Swift.Error`.
    /// All upstream publishers need to finish for this publisher to finish. If an upstream publisher never publishes a value, this publisher never finishes.
    /// If any of the combined publishers terminates with a failure, this publisher also fails.
    /// - Parameters:
    ///   - publisher1: A second publisher to combine with this one.
    ///   - publisher2: A third publisher to combine with this one.
    ///   - transform: A closure that receives the most recent value from each publisher and returns a new value to publish.
    /// - Returns: A publisher that receives and combines elements from this publisher and two other publishers.
    public func tryCombineLatest<P, Q, T>(_ publisher1: P, _ publisher2: Q, _ transform: @escaping (Self.Output, P.Output, Q.Output) throws -> T) -> Publishers.TryCombineLatest3<Self, P, Q, T> where P: Publisher, Q: Publisher, P.Failure == Error, Q.Failure == Error {
        return Publishers.TryCombineLatest3(a: self, b: publisher1, c: publisher2,  transform: transform)
    }
    
    /// Subscribes to three additional publishers and invokes an error-throwing closure upon receiving output from any of the publishers.
    ///
    /// The combined publisher passes through any requests to *all* upstream publishers. However, it still obeys the demand-fulfilling rule of only sending the request amount downstream. If the demand isn’t `.unlimited`, it drops values from upstream publishers. It implements this by using a buffer size of 1 for each upstream, and holds the most recent value in each buffer.
    /// If the provided transform throws an error, the publisher fails with the error. `Self.Failure`, `P.Failure`, `Q.Failure`, and `R.Failure` must all be `Swift.Error`.
    /// All upstream publishers need to finish for this publisher to finish. If an upstream publisher never publishes a value, this publisher never finishes.
    /// If any of the combined publishers terminates with a failure, this publisher also fails.
    /// - Parameters:
    ///   - publisher1: A second publisher to combine with this one.
    ///   - publisher2: A third publisher to combine with this one.
    ///   - publisher3: A fourth publisher to combine with this one.
    ///   - transform: A closure that receives the most recent value from each publisher and returns a new value to publish.
    /// - Returns: A publisher that receives and combines elements from this publisher and three other publishers.
    public func tryCombineLatest<P, Q, R, T>(_ publisher1: P, _ publisher2: Q, _ publisher3: R, _ transform: @escaping (Self.Output, P.Output, Q.Output, R.Output) throws -> T) -> Publishers.TryCombineLatest4<Self, P, Q, R, T> where P: Publisher, Q: Publisher, R: Publisher, P.Failure == Error, Q.Failure == Error, R.Failure == Error {
        return Publishers.TryCombineLatest4(a: self, b: publisher1, c: publisher2, d: publisher3, transform: transform)
    }
}
