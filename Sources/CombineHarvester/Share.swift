extension Publishers {
    /// A publisher implemented as a class, which otherwise behaves like its upstream publisher.
    public final class Share<Upstream>: Publisher, Equatable where Upstream: Publisher {
        public typealias Output = Upstream.Output
        public typealias Failure = Upstream.Failure

        private let upstream: Upstream

        fileprivate init(upstream: Upstream) {
            self.upstream = upstream
        }

        public final func receive<S: Subscriber>(subscriber: S) where Upstream.Failure == S.Failure, Upstream.Output == S.Input {
            self.upstream.subscribe(subscriber)
        }

        public static func == (lhs: Publishers.Share<Upstream>, rhs: Publishers.Share<Upstream>) -> Bool {
            if rhs === lhs {
                return true
            }
            guard let l = lhs.upstream as? AnyHashable, let r = rhs.upstream as? AnyHashable else {
                return false
            }
            return l == r
        }
    }
}

extension Publisher {
    /// Returns a publisher as a class instance.
    ///
    /// The downstream subscriber receieves elements and completion states unchanged from the upstream publisher. Use this operator when you want to use reference semantics, such as storing a publisher instance in a property.
    ///
    /// - Returns: A class instance that republishes its upstream publisher.
    public func share() -> Publishers.Share<Self> {
        return self as? Publishers.Share<Self> ?? Publishers.Share(upstream: self)
    }
}
