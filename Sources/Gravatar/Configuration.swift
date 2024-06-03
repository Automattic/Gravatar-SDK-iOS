import Foundation

/// Gravatar API Configuration
public actor Configuration {
    /// Authorisation key to gain access to extra features on the Gravatar API.
    private(set) var apiKey: String?

    /// Global configuration instance. Use this instance to configure the usage of the Gravatar API
    public static let shared = Configuration()

    private init() {}

    /// Updates the current configuration instance.
    /// - Parameter apiKey: The new authorisation API key.
    public func configure(with apiKey: String?) {
        self.apiKey = apiKey
    }
}
