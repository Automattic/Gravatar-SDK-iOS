import Foundation

/// A type that provides a hash that represents a gravatar profile
public struct HashID: Equatable, Sendable {
    let string: String

    /// Initializes a new `HashID` object, reprensenting the gravatar hash of the Gravatar email address
    /// - Parameter string: The gravatar hash of the Gravatar email address
    public init(_ string: String) {
        self.string = string
    }

    /// Initializes a new `HashID` object, reprensenting the gravatar hash of the Gravatar email address
    /// - Parameter email: an `Email` containing the Gravatar email address
    public init(email: Email) {
        self.init(email.string.hashed())
    }
}

extension HashID: Identifiable {
    /// The string that the API expects when specifying a Gravatar type, such as an avatar or profile
    public var id: String {
        string
    }
}
