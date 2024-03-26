import Foundation

public enum AvatarIdentifier {
    case email(Email)
    case hashId(HashID)
}

extension AvatarIdentifier {
    // MARK: - Convience factories

    public static func email(_ email: String) -> AvatarIdentifier {
        .email(.init(email))
    }

    public static func hashId(_ hashId: String) -> AvatarIdentifier {
        .hashId(.init(hashId))
    }
}

extension AvatarIdentifier: IdentifierProvider {
    // MARK: - IdentifierProvider

    public var identifier: String {
        switch self {
        case .email(let email):
            email.identifier
        case .hashId(let hashId):
            hashId.identifier
        }
    }
}
