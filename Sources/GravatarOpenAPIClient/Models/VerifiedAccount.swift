import Foundation

/// A verified account on a user's profile.
///
public struct VerifiedAccount: Codable, Hashable, Sendable {
    /// The type of the service.
    public private(set) var serviceType: String
    /// The name of the service.
    public private(set) var serviceLabel: String
    /// The URL to the service's icon.
    public private(set) var serviceIcon: String
    /// The URL to the user's profile on the service.
    public private(set) var url: String
    /// Whether the verified account is hidden from the user's profile.
    public private(set) var isHidden: Bool

    init(serviceType: String, serviceLabel: String, serviceIcon: String, url: String, isHidden: Bool) {
        self.serviceType = serviceType
        self.serviceLabel = serviceLabel
        self.serviceIcon = serviceIcon
        self.url = url
        self.isHidden = isHidden
    }

    enum CodingKeys: String, CodingKey, CaseIterable {
        case serviceType = "service_type"
        case serviceLabel = "service_label"
        case serviceIcon = "service_icon"
        case url
        case isHidden = "is_hidden"
    }

    // Encodable protocol methods

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(serviceType, forKey: .serviceType)
        try container.encode(serviceLabel, forKey: .serviceLabel)
        try container.encode(serviceIcon, forKey: .serviceIcon)
        try container.encode(url, forKey: .url)
        try container.encode(isHidden, forKey: .isHidden)
    }
}
