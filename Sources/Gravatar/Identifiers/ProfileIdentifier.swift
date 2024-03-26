import Foundation

public enum ProfileIdentifier {
    case email(Email)
    case hashID(HashID)
}

extension ProfileIdentifier {
    // MARK: - Convience factories

    public static func email(_ email: String) -> ProfileIdentifier {
        .email(.init(email))
    }

    public static func hashID(_ hashID: String) -> ProfileIdentifier {
        .hashID(.init(hashID))
    }
}

extension ProfileIdentifier: IdentifierProvider {
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
