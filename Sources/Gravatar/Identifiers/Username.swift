import Foundation

public struct Username {
    let string: String

    public init(_ string: String) {
        self.string = string
    }
}

extension Username: IdentifierProvider {
    public var identifier: String {
        self.string
    }
}
