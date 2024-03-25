import Foundation

/// An object representing the Gravatar account
public struct AccountIdentifier {
    let email: String
    let accessToken: String

    /// Initializes a new `AccountIdentifier` object
    /// - Parameters:
    ///   - email: Email address associated with the Gravatar account
    ///   - accessToken: An access token for authorizing access
    public init(email: String, accessToken: String) {
        self.email = email
        self.accessToken = accessToken
    }
}
