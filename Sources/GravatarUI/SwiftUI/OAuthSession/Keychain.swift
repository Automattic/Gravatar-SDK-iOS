import Foundation

protocol SecureStorage: Sendable {
    func setPassword(_ password: String, for key: String) throws
    func deletePassword(with key: String) throws
    func password(with key: String) throws -> String?
}

struct Keychain: SecureStorage {
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
            kSecValueData as String: tokenData,
        ]

        let status = SecItemAdd(query as CFDictionary, nil)
        if status != errSecSuccess {
            let message = SecCopyErrorMessageString(status, nil) as? String
            throw KeychainError.unhandledError(status: status, message: message)
        }
    }

    func password(with key: String) throws -> String? {
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
            kSecAttrAccount as String: key,
        ]
        let status = SecItemDelete(query as CFDictionary)
        if status != errSecSuccess && status != errSecItemNotFound {
            let message = SecCopyErrorMessageString(status, nil) as? String
            throw KeychainError.unhandledError(status: status, message: message)
        }
    }
}
