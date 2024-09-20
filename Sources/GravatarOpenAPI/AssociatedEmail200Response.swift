import Foundation

public struct AssociatedEmail200Response: Codable, Hashable, Sendable {
    /// Whether the email is associated with a Gravatar account.
    public private(set) var associated: Bool

    @available(*, deprecated, message: "init will become internal on the next release")
    public init(associated: Bool) {
        self.associated = associated
    }

    @available(*, deprecated, message: "CodingKeys will become internal on the next release.")
    public enum CodingKeys: String, CodingKey, CaseIterable {
        case associated
    }

    enum InternalCodingKeys: String, CodingKey, CaseIterable {
        case associated
    }

    // Encodable protocol methods

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: InternalCodingKeys.self)
        try container.encode(associated, forKey: .associated)
    }

    // Decodable protocol methods

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: InternalCodingKeys.self)

        associated = try container.decode(Bool.self, forKey: .associated)
    }
}
