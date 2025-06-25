import Foundation

struct GetVerifiedAccountServices200ResponseServicesInner: Codable, Hashable, Sendable {
    /// The identifier for the service.
    private(set) var id: String
    /// The human-readable label for the service.
    private(set) var label: String

    init(id: String, label: String) {
        self.id = id
        self.label = label
    }

    enum CodingKeys: String, CodingKey, CaseIterable {
        case id
        case label
    }

    // Encodable protocol methods

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(label, forKey: .label)
    }
}
