import Foundation

public struct HashID {
    let string: String

    public init(_ string: String) {
        self.string = string
    }

    public init(email: Email) {
        self.init(email.string.hashed())
    }
}

extension HashID: IdentifierProvider {
    public var identifier: String {
        self.string
    }
}
