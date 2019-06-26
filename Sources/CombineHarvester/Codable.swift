import Foundation

extension Publishers {
    public struct Decode<Upstream, Output, Coder>: Publisher where Upstream: Publisher, Output: Decodable, Coder: TopLevelDecoder, Upstream.Output == Coder.Input {
        public typealias Failure = Error

        public let upstream: Upstream

        private let decoder: Coder

        public init(upstream: Upstream, decoder: Coder) {
            self.upstream = upstream
            self.decoder = decoder
        }

        public func receive<S>(subscriber: S) where Output == S.Input, S: Subscriber, S.Failure == Failure {
            self.upstream
                .tryMap { try self.decoder.decode(Output.self, from: $0) }
                .subscribe(subscriber)
        }
    }

    public struct Encode<Upstream, Coder>: Publisher where Upstream: Publisher, Coder: TopLevelEncoder, Upstream.Output: Encodable {
        public typealias Failure = Error
        public typealias Output = Coder.Output

        public let upstream: Upstream

        private let encoder: Coder

        public init(upstream: Upstream, encoder: Coder) {
            self.upstream = upstream
            self.encoder = encoder
        }

        public func receive<S>(subscriber: S) where S: Subscriber, Coder.Output == S.Input, S.Failure == Publishers.Encode<Upstream, Coder>.Failure {
            self.upstream
                .tryMap(self.encoder.encode)
                .subscribe(subscriber)
        }
    }
}

extension Publisher {
    /// Decodes the output from upstream using a specified `TopLevelDecoder`.
    /// For example, use `JSONDecoder`.
    public func decode<Item, Coder>(type _: Item.Type, decoder: Coder) -> Publishers.Decode<Self, Item, Coder> where Item: Decodable, Coder: TopLevelDecoder, Self.Output == Coder.Input {
        return Publishers.Decode(upstream: self, decoder: decoder)
    }
}

extension Publisher where Self.Output: Encodable {
    /// Encodes the output from upstream using a specified `TopLevelEncoder`.
    /// For example, use `JSONEncoder`.
    public func encode<Coder>(encoder: Coder) -> Publishers.Encode<Self, Coder> where Coder: TopLevelEncoder {
        return Publishers.Encode(upstream: self, encoder: encoder)
    }
}

// MARK: -

public protocol TopLevelDecoder {
    associatedtype Input

    func decode<T>(_ type: T.Type, from: Self.Input) throws -> T where T: Decodable
}

public protocol TopLevelEncoder {
    associatedtype Output

    func encode<T>(_ value: T) throws -> Self.Output where T: Encodable
}

extension JSONEncoder: TopLevelEncoder {
}

extension JSONDecoder: TopLevelDecoder {
}
