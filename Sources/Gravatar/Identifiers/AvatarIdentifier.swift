import Foundation

public enum AvatarIdentifier {
    case email(Email)
    case hashID(HashID)
}

extension AvatarIdentifier {
    // MARK: - Convience factories

    public static func email(_ email: String) -> AvatarIdentifier {
        .email(.init(email))
    }

    public static func hashID(_ hashID: String) -> AvatarIdentifier {
        .hashID(.init(hashID))
    }
}

extension AvatarIdentifier: IdentifierProvider {
    // MARK: - IdentifierProvider

    public var identifier: String {
        switch self {
        case .email(let email):
            email.identifier
        case .hashID(let hashID):
            hashID.identifier
        }
    }
}
