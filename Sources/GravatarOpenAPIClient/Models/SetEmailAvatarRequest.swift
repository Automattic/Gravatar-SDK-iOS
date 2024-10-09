import Foundation

public struct SetEmailAvatarRequest: Codable, Hashable, Sendable {
    /// The email SHA256 hash to set the avatar for.
    public private(set) var emailHash: String

    @available(*, deprecated, message: "init will become internal on the next release")
    public init(emailHash: String) {
        self.emailHash = emailHash
    }

    @available(*, deprecated, message: "CodingKeys will become internal on the next release.")
    public enum CodingKeys: String, CodingKey, CaseIterable {
        case emailHash = "email_hash"
    }

    enum InternalCodingKeys: String, CodingKey, CaseIterable {
        case emailHash = "email_hash"
    }

    // Encodable protocol methods

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: InternalCodingKeys.self)
        try container.encode(emailHash, forKey: .emailHash)
    }

    // Decodable protocol methods

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: InternalCodingKeys.self)

        emailHash = try container.decode(String.self, forKey: .emailHash)
    }
}
