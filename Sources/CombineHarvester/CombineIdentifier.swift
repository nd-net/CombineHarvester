
public struct CombineIdentifier: Hashable, CustomStringConvertible {
    private let identifier: AnyObject?

    public init() {
        self.identifier = nil
    }

    public init(_ obj: AnyObject) {
        self.identifier = obj
    }

    public var description: String {
        guard let identifier = self.identifier else {
            return "<anonymous>"
        }
        if let convertible = identifier as? CustomStringConvertible {
            return convertible.description
        }
        let address = Unmanaged.passUnretained(identifier).toOpaque()
        return "CombineIdentifier: \(address.debugDescription)"
    }

    public func hash(into hasher: inout Hasher) {
        if let hashable = self.identifier as? AnyHashable {
            hashable.hash(into: &hasher)
        }
    }

    public static func == (lhs: CombineIdentifier, rhs: CombineIdentifier) -> Bool {
        guard let l = lhs.identifier as? AnyHashable, let r = rhs.identifier as? AnyHashable else {
            return false
        }
        return l == r
    }
}

public protocol CustomCombineIdentifierConvertible {
    var combineIdentifier: CombineIdentifier { get }
}

extension CustomCombineIdentifierConvertible where Self: AnyObject {
    public var combineIdentifier: CombineIdentifier {
        return CombineIdentifier(self)
    }
}
