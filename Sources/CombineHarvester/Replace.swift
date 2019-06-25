
extension Publishers {
    /// A publisher that replaces an empty stream with a provided element.
    public struct ReplaceEmpty<Upstream>: Publisher where Upstream: Publisher {
        public typealias Output = Upstream.Output
        public typealias Failure = Upstream.Failure

        /// The element to deliver when the upstream publisher finishes without delivering any elements.
        public let output: Output

        /// The publisher from which this publisher receives elements.
        public let upstream: Upstream

        public init(upstream: Upstream, output: Output) {
            self.upstream = upstream
            self.output = output
        }

        public func receive<S>(subscriber: S) where S: Subscriber, Upstream.Failure == S.Failure, Upstream.Output == S.Input {
            var isEmpty = true
            self.upstream.subscribe(TransformingSubscriber(
                subscriber: subscriber,
                transformRequest: { [.demand($0)] },
                transformValue: { value in
                    isEmpty = false
                    return [.value(value)]
                }, transformCompletion: { completion in
                    switch completion {
                    case .finished:
                        if isEmpty {
                            return [.value(self.output), .finished]
                        }
                        return [.finished]
                    case let .failure(error):
                        return [.failure(error)]
                    }
                }
            ))
        }
    }

    /// A publisher that replaces any errors in the stream with a provided element.
    public struct ReplaceError<Upstream>: Publisher where Upstream: Publisher {
        public typealias Output = Upstream.Output
        public typealias Failure = Never

        /// The element with which to replace errors from the upstream publisher.
        public let output: Output

        /// The publisher from which this publisher receives elements.
        public let upstream: Upstream

        public init(upstream: Upstream, output: Output) {
            self.upstream = upstream
            self.output = output
        }

        /// This function is called to attach the specified `Subscriber` to this `Publisher` by `subscribe(_:)`
        ///
        /// - SeeAlso: `subscribe(_:)`
        /// - Parameters:
        ///     - subscriber: The subscriber to attach to this `Publisher`.
        ///                   once attached it can begin to receive values.
        public func receive<S>(subscriber: S) where S: Subscriber, Upstream.Output == S.Input, S.Failure == Failure {
            self.upstream.subscribe(TransformingSubscriber<Output, Upstream.Failure, Output, Never>(
                subscriber: subscriber,
                transformRequest: { [.demand($0)] },
                transformValue: { [.value($0)] },
                transformCompletion: { completion in
                    switch completion {
                    case .finished:
                        return [.finished]
                    case .failure:
                        return [.value(self.output), .finished]
                    }
                }
            ))
        }
    }
}

extension Publishers.ReplaceEmpty: Equatable where Upstream: Equatable, Upstream.Output: Equatable {
    public static func == (lhs: Publishers.ReplaceEmpty<Upstream>, rhs: Publishers.ReplaceEmpty<Upstream>) -> Bool {
        return lhs.upstream == rhs.upstream && lhs.output == rhs.output
    }
}

extension Publishers.ReplaceError: Equatable where Upstream: Equatable, Upstream.Output: Equatable {
    public static func == (lhs: Publishers.ReplaceError<Upstream>, rhs: Publishers.ReplaceError<Upstream>) -> Bool {
        return lhs.upstream == rhs.upstream && lhs.output == rhs.output
    }
}

extension Publisher {
    /// Replaces any errors in the stream with the provided element.
    ///
    /// If the upstream publisher fails with an error, this publisher emits the provided element, then finishes normally.
    /// - Parameter output: An element to emit when the upstream publisher fails.
    /// - Returns: A publisher that replaces an error from the upstream publisher with the provided output element.
    public func replaceError(with output: Self.Output) -> Publishers.ReplaceError<Self> {
        return Publishers.ReplaceError(upstream: self, output: output)
    }

    /// Replaces an empty stream with the provided element.
    ///
    /// If the upstream publisher finishes without producing any elements, this publisher emits the provided element, then finishes normally.
    /// - Parameter output: An element to emit when the upstream publisher finishes without emitting any elements.
    /// - Returns: A publisher that replaces an empty stream with the provided output element.
    public func replaceEmpty(with output: Self.Output) -> Publishers.ReplaceEmpty<Self> {
        return Publishers.ReplaceEmpty(upstream: self, output: output)
    }
}
