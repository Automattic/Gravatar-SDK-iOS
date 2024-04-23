import Foundation

/// Represents a Gravatar account email address
public struct Email: Equatable {
    let string: String

    var hashID: HashID {
        HashID(email: self)
    }

    /// Initializes a new Email object, representing a Gravatar account email address
    /// - Parameter string: The Gravatar account email address`
    public init(_ string: String) {
        self.string = string.sanitized
    }
}

extension Email: Identifiable {
    /// The string that the API expects when specifying a Gravatar type, such as an avatar or profile
    public var id: String {
        self.hashID.id
    }
}

extension Email: RawRepresentable {
    public init?(rawValue: String) {
        self.init(rawValue)
    }

    public var rawValue: String {
        string
    }
}
