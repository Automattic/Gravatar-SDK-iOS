import CryptoKit
import Foundation

extension String {
    func sha256() -> String {
        let hashed = SHA256.hash(data: Data(self.utf8))
        let hashString = hashed.compactMap { String(format: "%02x", $0) }.joined()
        return hashString
    }
}
