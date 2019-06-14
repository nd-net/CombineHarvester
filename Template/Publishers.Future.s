
extension Publishers {
    /// A publisher that eventually produces one value and then finishes or fails.
    public final class Future<Output, Failure>: Publisher where Failure: Error {
        
        private let attemptToFulfill:  ( @escaping(Result<Output, Failure>) -> Void) -> Void
        
        public init(_ attemptToFulfill: @escaping (@escaping (Result<Output, Failure>) -> Void) -> Void) {
            self.attemptToFulfill = attemptToFulfill
        }
        
        /// This function is called to attach the specified `Subscriber` to this `Publisher` by `subscribe(_:)`
        ///
        /// - SeeAlso: `subscribe(_:)`
        /// - Parameters:
        ///     - subscriber: The subscriber to attach to this `Publisher`.
        ///                   once attached it can begin to receive values.
        public final func receive<S>(subscriber: S) where Output == S.Input, Failure == S.Failure, S: Subscriber { notImplemented() }
        
    }
}
