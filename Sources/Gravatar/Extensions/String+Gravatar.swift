import CryptoKit
import Foundation

extension String {
    func hashId() -> String {
        self
            .normalized()
            .sha256()
    }

    func normalized() -> String {
        self
            .lowercased()
            .trimmingCharacters(in: .whitespaces)
    }

    private func sha256() -> String {
        let hashed = SHA256.hash(data: Data(self.utf8))
        let hashString = hashed.compactMap { String(format: "%02x", $0) }.joined()
        return hashString
    }
}
