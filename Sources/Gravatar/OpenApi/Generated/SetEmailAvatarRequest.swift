import Foundation

struct SetEmailAvatarRequest: Codable, Hashable, Sendable {
    /// The email SHA256 hash to set the avatar for.
    private(set) var emailHash: String

    enum InternalCodingKeys: String, CodingKey, CaseIterable {
        case emailHash = "email_hash"
    }

    // Encodable protocol methods

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: InternalCodingKeys.self)
        try container.encode(emailHash, forKey: .emailHash)
    }

    // Decodable protocol methods

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: InternalCodingKeys.self)

        emailHash = try container.decode(String.self, forKey: .emailHash)
    }
}
