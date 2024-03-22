import Foundation

public struct HashId {
    let string: String

    public init(_ string: String) {
        self.string = string
    }

    public init(email: Email) {
        self.init(email.string.hashId())
    }
}

extension HashId: ProfileIdentifierProvider {
    public var identifier: String {
        self.string
    }
}
