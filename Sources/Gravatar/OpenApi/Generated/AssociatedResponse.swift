import Foundation

struct AssociatedResponse: Codable, Hashable, Sendable {
    /// Whether the entity is associated with the account.
    private(set) var associated: Bool

    init(associated: Bool) {
        self.associated = associated
    }

    enum CodingKeys: String, CodingKey, CaseIterable {
        case associated
    }

    // Encodable protocol methods

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(associated, forKey: .associated)
    }
}
