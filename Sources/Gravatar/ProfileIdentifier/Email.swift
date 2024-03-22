import Foundation

public struct Email {
    let string: String

    var hashId: HashId {
        HashId(email: self)
    }

    public init(_ string: String) {
        self.string = string.normalized()
    }
}

extension Email: ProfileIdentifierProvider {
    public var identifier: String {
        self.hashId.identifier
    }
}
