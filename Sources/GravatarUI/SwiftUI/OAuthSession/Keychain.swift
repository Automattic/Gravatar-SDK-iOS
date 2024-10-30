import Foundation

protocol SecureStorage: Sendable {
    func setSecret(_ secret: KeychainToken, for key: String) throws
    func deleteSecret(with key: String) throws
    func secret(with key: String) throws -> KeychainToken?
}

struct Keychain: SecureStorage {
    enum KeychainError: Error {
        case unexpectedSecretData
        case cannotConvertSecretIntoData
        case unhandledError(status: OSStatus, message: String?)
    }

    func setSecret(_ secret: KeychainToken, for key: String) throws {
        guard let tokenData = secret.data else {
            throw KeychainError.cannotConvertSecretIntoData
        }

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: tokenData,
        ]

        let status = SecItemAdd(query as CFDictionary, nil)
        if status != errSecSuccess {
            let message = SecCopyErrorMessageString(status, nil) as? String
            throw KeychainError.unhandledError(status: status, message: message)
        }
    }

    func secret(with key: String) throws -> KeychainToken? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecMatchLimit as String: kSecMatchLimitOne,
            kSecAttrAccount as String: key,
            kSecReturnAttributes as String: true,
            kSecReturnData as String: true,
        ]

        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)

        guard status == errSecSuccess else {
            let message = SecCopyErrorMessageString(status, nil) as? String
            throw KeychainError.unhandledError(status: status, message: message)
        }

        guard
            let existingItem = item as? [String: Any],
            let secretData = existingItem[kSecValueData as String] as? Data,
            let secret = KeychainToken(data: secretData)
        else {
            throw KeychainError.unexpectedSecretData
        }

        return secret
    }

    func deleteSecret(with key: String) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
        ]
        let status = SecItemDelete(query as CFDictionary)
        if status != errSecSuccess && status != errSecItemNotFound {
            let message = SecCopyErrorMessageString(status, nil) as? String
            throw KeychainError.unhandledError(status: status, message: message)
        }
    }
}
