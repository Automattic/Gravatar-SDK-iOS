import Foundation

struct AssociatedResponse: Codable, Hashable, Sendable {
    /// Whether the entity is associated with the account.
    private(set) var associated: Bool

    @available(*, deprecated, message: "init will become internal on the next release")
    init(associated: Bool) {
        self.associated = associated
    }

    @available(*, deprecated, message: "CodingKeys will become internal on the next release.")
    enum CodingKeys: String, CodingKey, CaseIterable {
        case associated
    }

    enum InternalCodingKeys: String, CodingKey, CaseIterable {
        case associated
    }

    // Encodable protocol methods

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: InternalCodingKeys.self)
        try container.encode(associated, forKey: .associated)
    }

    // Decodable protocol methods

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: InternalCodingKeys.self)

        associated = try container.decode(Bool.self, forKey: .associated)
    }
}
