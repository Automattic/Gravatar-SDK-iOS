import Foundation

struct SearchProfilesByVerifiedAccount200Response: Codable, Hashable, Sendable {
    private(set) var profiles: [Profile]
    /// Total number of pages available.
    private(set) var totalPages: Int

    init(profiles: [Profile], totalPages: Int) {
        self.profiles = profiles
        self.totalPages = totalPages
    }

    enum CodingKeys: String, CodingKey, CaseIterable {
        case profiles
        case totalPages = "total_pages"
    }

    // Encodable protocol methods

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(profiles, forKey: .profiles)
        try container.encode(totalPages, forKey: .totalPages)
    }
}
