import Foundation

public protocol ProfileIdentifierProvider {
    var identifier: String { get }
}

public enum ProfileIdentifier: ProfileIdentifierProvider {
    case username(Username)
    case email(Email)
    case hashId(HashId)

    public var identifier: String {
        switch self {
        case .username(let username):
            username.identifier
        case .email(let email):
            email.identifier
        case .hashId(let hashId):
            hashId.identifier
        }
    }

    public static func username(_ username: String) -> ProfileIdentifier {
        .username(.init(username))
    }

    public static func email(_ email: String) -> ProfileIdentifier {
        .email(.init(email))
    }

    public static func hashId(_ hashId: String) -> ProfileIdentifier {
        .hashId(.init(hashId))
    }
}
