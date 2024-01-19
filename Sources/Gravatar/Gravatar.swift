import Foundation
import CryptoKit

#if canImport(SwiftUI)
import SwiftUI

public struct GravatarImage: View {

    private let url: URL

    public init(email: String) {
        let hash = GravatarDataProvider.hash(email: "test@example.com")
        self.url = URL(string: "https://gravatar.com/avatar/")!.appendingPathComponent(hash)
    }

    public var body: some View {
        AsyncImage(url: self.url)
    }
}
#endif

struct GravatarDataProvider {
    static func hash(email: String) -> String {
        let hash = SHA256.hash(data: email.data(using: .utf8)!)
        return hash.compactMap { String(format: "%02x", $0) }.joined()
    }
}
