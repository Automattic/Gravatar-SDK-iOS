import Foundation
import SensitiveContentAnalysis

@globalActor
public actor ConfigActor: GlobalActor {
    public static let shared = ConfigActor()
}

/// Gravatar API Configuration
@ConfigActor
public final class Configuration {
    public struct Auth: Sendable {
        package let clientID: String
        package let clientSecret: String
        package let redirectURI: String

        public init(clientID: String, clientSecret: String, redirectURI: String) {
            self.clientID = clientID
            self.clientSecret = clientSecret
            self.redirectURI = redirectURI
        }
    }

    /// Authorisation key to gain access to extra features on the Gravatar API.
    private(set) var apiKey: String?
    package private(set) var auth: Auth?

    /// Global configuration instance. Use this instance to configure the usage of the Gravatar API
    public static let shared = Configuration()

    private init() {}

    /// Updates the current configuration instance.
    /// - Parameter apiKey: The new authorisation API key.
    public func configure(apiKey: String? = nil, auth: Auth? = nil) {
        self.apiKey = apiKey
        self.auth = auth
    }

    package func setUserAuthorizationToken(_ token: String?, for id: ProfileIdentifier) throws {
        let keychain = Keychain()
        if let token {
            try keychain.setPassword(token, for: id.id)
        } else {
            try keychain.deletePassword(with: id.id)
        }
    }

    package func userAuthorizationToken(for id: ProfileIdentifier) -> String? {
        let keychain = Keychain()
        return try? keychain.password(with: id.id)
    }
}

struct Keychain {
    enum KeychainError: Error {
        case unexpectedPasswordData
        case cannotConvertPasswordIntoData
        case unhandledError(status: OSStatus, message: String?)
    }

    func setPassword(_ password: String, for key: String) throws {
        guard let tokenData = password.data(using: .utf8) else {
            throw KeychainError.cannotConvertPasswordIntoData
        }

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: tokenData
        ]

        let status = SecItemAdd(query as CFDictionary, nil)
        if status != errSecSuccess {
            let message = SecCopyErrorMessageString(status, nil) as? String
            throw KeychainError.unhandledError(status: status, message: message)
        }
    }

    package func password(with key: String) throws -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecMatchLimit as String: kSecMatchLimitOne,
            kSecAttrAccount as String: key,
            kSecReturnAttributes as String: true,
            kSecReturnData as String: true
        ]

        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)

        guard status == errSecSuccess else {
            let message = SecCopyErrorMessageString(status, nil) as? String
            throw KeychainError.unhandledError(status: status, message: message)
        }

        guard 
            let existingItem = item as? [String : Any],
            let passwordData = existingItem[kSecValueData as String] as? Data,
            let password = String(data: passwordData, encoding: .utf8)
        else {
            throw KeychainError.unexpectedPasswordData
        }

        return password
    }

    func deletePassword(with key: String) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ]
        let status = SecItemDelete(query as CFDictionary)
        if status != errSecSuccess && status != errSecItemNotFound {
            let message = SecCopyErrorMessageString(status, nil) as? String
            throw KeychainError.unhandledError(status: status, message: message)
        }
    }
}
