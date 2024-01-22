import Foundation
import CryptoKit

public struct GravatarDataProvider {
    static func hash(email: String) -> String {
        let hash = SHA256.hash(data: email.data(using: .utf8)!)
        return hash.compactMap { String(format: "%02x", $0) }.joined()
    }
}
