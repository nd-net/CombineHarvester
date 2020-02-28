extension Subscribers {
    /// A signal that a publisher doesn’t produce additional elements, either due to normal completion or an error.
    ///
    /// - finished: The publisher finished normally.
    /// - failure: The publisher stopped publishing due to the indicated error.
    public enum Completion<Failure: Error> {
        case finished
        case failure(Failure)
    }
}

extension Subscribers.Completion: Equatable where Failure: Equatable {
}

extension Subscribers.Completion: Hashable where Failure: Hashable {
}

private enum CodingKeys: String, CodingKey {
    case status
    case failure
}

private enum CompletionStatus: String, Codable {
    case finished
    case failure
}

extension Subscribers.Completion: Encodable where Failure: Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .finished:
            try container.encode(CompletionStatus.finished, forKey: .status)
        case let .failure(failure):
            try container.encode(CompletionStatus.failure, forKey: .status)
            try container.encode(failure, forKey: .failure)
        }
    }
}

extension Subscribers.Completion: Decodable where Failure: Decodable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let status = try container.decode(CompletionStatus.self, forKey: .status)
        switch status {
        case .finished:
            self = .finished
        case .failure:
            self = .failure(try container.decode(Failure.self, forKey: .failure))
        }
    }
}
