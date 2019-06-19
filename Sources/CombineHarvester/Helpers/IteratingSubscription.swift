/// An `IteratingSubscription` iterates through `Result` elements and forwards those elements (and errors).
///
/// The iteration stops at the end of the iterator *or* at the first failure from the iterator.
class IteratingSubscription<Element, Failure: Error>: Subscription {
    typealias IterationElement = Result<Element, Failure>
    typealias NextResult = () -> IterationElement?
    typealias ReceiveValue = (Element) -> Subscribers.Demand
    typealias ReceiveCompletion = (Subscribers.Completion<Failure>) -> Void

    private let nextResult: NextResult
    private let receiveValue: ReceiveValue
    private var receiveCompletion: Atomic<ReceiveCompletion?>

    /// Uses the iterator's `.next()` method.
    ///
    /// - Parameters:
    ///   - iterator: The iterator that whose next method should be called for nextResult
    ///   - subscriber: The subscriber whose receive functions should be forwarded.
    convenience init<I: IteratorProtocol, S: Subscriber>(iterator: I, subscriber: S) where I.Element == IterationElement, S.Input == Element, S.Failure == Failure {
        var iterator = iterator
        self.init(nextResult: { iterator.next() }, subscriber: subscriber)
    }

    /// Uses the subscriber's `.receive()` and `.receive(completion:)` methods.
    ///
    /// The subscriber's. `.receive(subscription:)` method *does not* get called by this initializer.
    ///
    /// - Parameters:
    ///   - nextResult: A closure to execute for getting the next element of the iteration.
    ///   - subscriber: The subscriber whose receive functions should be forwarded.
    convenience init<S: Subscriber>(nextResult: @escaping NextResult, subscriber: S) where S.Input == Element, S.Failure == Failure {
        self.init(nextResult: nextResult, receiveValue: subscriber.receive, receiveCompletion: subscriber.receive(completion:))
    }

    /// Uses the iterator's `.next()` method.
    ///
    /// - Parameters:
    ///   - iterator: The iterator that whose next method should be called for nextResult
    ///   - receiveValue: A closure to execute when the subscriber receives a value from the publisher.
    ///   - receiveCompletion: A closure to execute when the subscriber receives a completion callback from the publisher.
    convenience init<I: IteratorProtocol>(iterator: I, receiveValue: @escaping ReceiveValue, receiveCompletion: @escaping ReceiveCompletion) where I.Element == IterationElement {
        var iterator = iterator
        self.init(nextResult: { iterator.next() }, receiveValue: receiveValue, receiveCompletion: receiveCompletion)
    }

    /// Creates an iterating subscription that executes the provided closures.
    ///
    /// - Parameters:
    ///   - nextResult: A closure to execute for getting the next element of the iteration.
    ///   - receiveValue: A closure to execute when the subscriber receives a value from the publisher.
    ///   - receiveCompletion: A closure to execute when the subscriber receives a completion callback from the publisher.
    init(nextResult: @escaping NextResult, receiveValue: @escaping ReceiveValue, receiveCompletion: @escaping ReceiveCompletion) {
        self.nextResult = nextResult
        self.receiveValue = receiveValue
        self.receiveCompletion = Atomic(value: receiveCompletion)
    }

    func complete(failure: Failure?) {
        guard let receiveCompletion = self.receiveCompletion.swap(nil) else {
            return
        }
        if let failure = failure {
            receiveCompletion(.failure(failure))
        } else {
            receiveCompletion(.finished)
        }
    }

    func request(_ demand: Subscribers.Demand) {
        guard demand > 0 else {
            return
        }
        var demand = demand
        while demand > 0, self.receiveCompletion.value != nil {
            demand -= 1
            guard let result = nextResult() else {
                self.complete(failure: nil)
                return
            }
            switch result {
            case let .success(value):
                demand += self.receiveValue(value)
            case let .failure(failure):
                self.complete(failure: failure)
                return
            }
        }
    }

    func cancel() {
        self.receiveCompletion.value = nil
    }

    deinit {
        self.cancel()
    }
}
