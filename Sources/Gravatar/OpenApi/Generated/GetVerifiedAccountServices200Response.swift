import Foundation

struct GetVerifiedAccountServices200Response: Codable, Hashable, Sendable {
    /// List of supported verified account services.
    private(set) var services: [GetVerifiedAccountServices200ResponseServicesInner]

    init(services: [GetVerifiedAccountServices200ResponseServicesInner]) {
        self.services = services
    }

    enum CodingKeys: String, CodingKey, CaseIterable {
        case services
    }

    // Encodable protocol methods

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(services, forKey: .services)
    }
}
