import Foundation

/// Gravatar API Configuration
public actor Configuration {
    public struct OAuthSecrets: Sendable {
        package let clientID: String
        package let redirectURI: String
        package var callbackScheme: String {
            URLComponents(string: redirectURI)?.scheme ?? ""
        }

        public init(clientID: String, redirectURI: String) {
            self.clientID = clientID
            self.redirectURI = redirectURI
        }
    }

    /// Authorisation key to gain access to extra features on the Gravatar API.
    public private(set) var apiKey: String?
    package private(set) var oauthSecrets: OAuthSecrets?

    /// Global configuration instance. Use this instance to configure the usage of the Gravatar API
    public static let shared = Configuration()

    private init() {}

    /// Updates the current configuration instance.
    /// - Parameter apiKey: The new authorisation API key.
    public func configure(with apiKey: String?, oauthSecrets: OAuthSecrets? = nil) {
        self.apiKey = apiKey
        self.oauthSecrets = oauthSecrets
    }
}
