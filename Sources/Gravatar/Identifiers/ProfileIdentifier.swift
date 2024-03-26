import Foundation

public enum ProfileIdentifier {
    case email(Email)
    case hashId(HashId)
}

extension ProfileIdentifier {
    // MARK: - Convience factories

    public static func email(_ email: String) -> ProfileIdentifier {
        .email(.init(email))
    }

    public static func hashId(_ hashId: String) -> ProfileIdentifier {
        .hashId(.init(hashId))
    }
}

extension ProfileIdentifier: IdentifierProvider {
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
