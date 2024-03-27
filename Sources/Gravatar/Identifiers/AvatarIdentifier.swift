import Foundation

/// An identifier used for interacting with the `AvatarService`
///
/// The `AvatarService` uses an `AvatarIdentifer` to specifiy which avatar to fetch.
public enum AvatarIdentifier {
    case email(Email)
    case hashID(HashID)
}

extension AvatarIdentifier {
    // MARK: - Convience factories

    /// Creates an `AvatarIdenfitier` using an email address passed as a `String`
    /// - Parameter email: an email address
    /// - Returns: an `AvatarIdentifier`
    public static func email(_ email: String) -> AvatarIdentifier {
        .email(.init(email))
    }

    /// Creates an `AvatarIdenfitier` using a hash  passed as a `String`
    /// - Parameter hashId: a properly formatted hashID
    /// - Returns: an `AvatarIdentifier`
    public static func hashID(_ hashID: String) -> AvatarIdentifier {
        .hashID(.init(hashID))
    }
}

extension AvatarIdentifier: Identifiable {
    /// The string that the API expects for specifying an avatar.
    public var id: String {
        switch self {
        case .email(let email):
            email.id
        case .hashID(let hashID):
            hashID.id
        }
    }
}
