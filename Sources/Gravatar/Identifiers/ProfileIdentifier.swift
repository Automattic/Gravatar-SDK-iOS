import Foundation

/// An identifier used for interacting with the `ProfileService`
///
/// The `ProfileService` uses an `ProfileIdentifier` to specifiy which avatar to fetch.  The `ProfileService` allows specifying a profile
/// by either its email address or the hashID
public enum ProfileIdentifier {
    case email(Email)
    case hashID(HashID)
}

extension ProfileIdentifier {
    // MARK: - Convience factories

    /// Creates a `ProfileIdenfitier` using an email address passed as a `String`
    /// - Parameter email: an email address
    /// - Returns: a `ProfileIdentifier`
    public static func email(_ email: String) -> ProfileIdentifier {
        .email(.init(email))
    }

    /// Creates a `ProfileIdenfitier` using a hash  passed as a `String`
    /// - Parameter hashID: a properly formatted hashID
    /// - Returns: a `ProfileIdentifier`
    public static func hashID(_ hashID: String) -> ProfileIdentifier {
        .hashID(.init(hashID))
    }
}

extension ProfileIdentifier: Identifiable {
    /// The string that the API expects for specifying a profile.
    public var id: String {
        switch self {
        case .email(let email):
            email.id
        case .hashID(let hashID):
            hashID.id
        }
    }
}
