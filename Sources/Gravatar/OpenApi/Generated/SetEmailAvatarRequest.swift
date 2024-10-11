import Foundation

struct SetEmailAvatarRequest: Codable, Hashable, Sendable {
    /// The email SHA256 hash to set the avatar for.
    private(set) var emailHash: String

    init(emailHash: String) {
        self.emailHash = emailHash
    }

    enum CodingKeys: String, CodingKey, CaseIterable {
        case emailHash = "email_hash"
    }

    // Encodable protocol methods

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(emailHash, forKey: .emailHash)
    }
}
