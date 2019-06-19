public struct CombineIdentifier: Hashable, CustomStringConvertible {
    private let identifier: AnyObject

    public init() {
        class Identifier {
        }
        self.init(Identifier())
    }

    public init(_ obj: AnyObject) {
        self.identifier = obj
    }

    private var opaqueIdentifier: UnsafeMutableRawPointer {
        return Unmanaged.passUnretained(self.identifier).toOpaque()
    }

    public var description: String {
        return "CombineIdentifier: \(self.opaqueIdentifier.debugDescription)"
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.opaqueIdentifier)
    }

    public static func == (lhs: CombineIdentifier, rhs: CombineIdentifier) -> Bool {
        return lhs.identifier === rhs.identifier
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
