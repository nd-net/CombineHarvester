import Darwin
extension Publishers {
    /// A publisher that raises a debugger signal when a provided closure needs to stop the process in the debugger.
    ///
    /// When any of the provided closures returns `true`, this publisher raises the `SIGTRAP` signal to stop the process in the debugger.
    /// Otherwise, this publisher passes through values and completions as-is.
    public struct Breakpoint<Upstream: Publisher>: Publisher {
        public typealias Output = Upstream.Output
        public typealias Failure = Upstream.Failure

        /// The publisher from which this publisher receives elements.
        public let upstream: Upstream

        /// A closure that executes when the publisher receives a subscription, and can raise a debugger signal by returning a true Boolean value.
        public let receiveSubscription: ((Subscription) -> Bool)?

        /// A closure that executes when the publisher receives output from the upstream publisher, and can raise a debugger signal by returning a true Boolean value.
        public let receiveOutput: ((Output) -> Bool)?

        /// A closure that executes when the publisher receives completion, and can raise a debugger signal by returning a true Boolean value.
        public let receiveCompletion: ((Subscribers.Completion<Failure>) -> Bool)?

        /// Creates a breakpoint publisher with the provided upstream publisher and breakpoint-raising closures.
        ///
        /// - Parameters:
        ///   - upstream: The publisher from which this publisher receives elements.
        ///   - receiveSubscription: A closure that executes when the publisher receives a subscription, and can raise a debugger signal by returning a true Boolean value.
        ///   - receiveOutput: A closure that executes when the publisher receives output from the upstream publisher, and can raise a debugger signal by returning a true Boolean value.
        ///   - receiveCompletion: A closure that executes when the publisher receives completion, and can raise a debugger signal by returning a true Boolean value.
        public init(upstream: Upstream, receiveSubscription: ((Subscription) -> Bool)? = nil, receiveOutput: ((Output) -> Bool)? = nil, receiveCompletion: ((Subscribers.Completion<Failure>) -> Bool)? = nil) {
            self.upstream = upstream
            self.receiveSubscription = receiveSubscription
            self.receiveOutput = receiveOutput
            self.receiveCompletion = receiveCompletion
        }

        private func decorate<P, R>(original: @escaping (P) -> R, trap: ((P) -> Bool)?) -> (P) -> R {
            guard let trap = trap else {
                return original
            }
            return { value in
                if trap(value) {
                    Darwin.raise(Darwin.SIGTRAP)
                }
                return original(value)
            }
        }

        public func receive<S: Subscriber>(subscriber: S) where Failure == S.Failure, Output == S.Input {
            guard self.receiveSubscription != nil || self.receiveOutput != nil || self.receiveCompletion != nil else {
                self.upstream.subscribe(subscriber)
                return
            }

            let breakpointSubscriber = AnySubscriber<S.Input, S.Failure>(
                receiveSubscription: decorate(original: subscriber.receive(subscription:), trap: self.receiveSubscription),
                receiveValue: self.decorate(original: subscriber.receive, trap: self.receiveOutput),
                receiveCompletion: self.decorate(original: subscriber.receive(completion:), trap: self.receiveCompletion)
            )
            self.upstream.subscribe(breakpointSubscriber)
        }
    }
}

extension Publisher {
    /// Raises a debugger signal when a provided closure needs to stop the process in the debugger.
    ///
    /// When any of the provided closures returns `true`, this publisher raises the `SIGTRAP` signal to stop the process in the debugger.
    /// Otherwise, this publisher passes through values and completions as-is.
    ///
    /// - Parameters:
    ///   - receiveSubscription: A closure that executes when when the publisher receives a subscription. Return `true` from this closure to raise `SIGTRAP`, or false to continue.
    ///   - receiveOutput: A closure that executes when when the publisher receives a value. Return `true` from this closure to raise `SIGTRAP`, or false to continue.
    ///   - receiveCompletion: A closure that executes when when the publisher receives a completion. Return `true` from this closure to raise `SIGTRAP`, or false to continue.
    /// - Returns: A publisher that raises a debugger signal when one of the provided closures returns `true`.
    public func breakpoint(receiveSubscription: ((Subscription) -> Bool)? = nil, receiveOutput: ((Self.Output) -> Bool)? = nil, receiveCompletion: ((Subscribers.Completion<Self.Failure>) -> Bool)? = nil) -> Publishers.Breakpoint<Self> {
        return Publishers.Breakpoint(upstream: self, receiveSubscription: receiveSubscription, receiveOutput: receiveOutput, receiveCompletion: receiveCompletion)
    }

    /// Raises a debugger signal upon receiving a failure.
    ///
    /// When the upstream publisher fails with an error, this publisher raises the `SIGTRAP` signal, which stops the process in the debugger.
    /// Otherwise, this publisher passes through values and completions as-is.
    /// - Returns: A publisher that raises a debugger signal upon receiving a failure.
    public func breakpointOnError() -> Publishers.Breakpoint<Self> {
        return self.breakpoint(receiveCompletion: { completion in
            switch completion {
            case .finished:
                return false
            case .failure:
                return true
            }
        })
    }
}
