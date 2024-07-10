import Foundation

/// A verified account on a user's profile.
///
public struct VerifiedAccount: Codable, Hashable, Sendable {
    /// The name of the service.
    public private(set) var serviceLabel: String
    /// The URL to the service's icon.
    public private(set) var serviceIcon: String
    /// The URL to the user's profile on the service.
    public private(set) var url: String

    @available(*, deprecated, message: "init will become internal on the next release")
    public init(serviceLabel: String, serviceIcon: String, url: String) {
        self.serviceLabel = serviceLabel
        self.serviceIcon = serviceIcon
        self.url = url
    }

    @available(*, deprecated, message: "CodingKeys will become internal on the next release.")
    public enum CodingKeys: String, CodingKey, CaseIterable {
        case serviceLabel = "service_label"
        case serviceIcon = "service_icon"
        case url
    }

    enum InternalCodingKeys: String, CodingKey, CaseIterable {
        case serviceLabel = "service_label"
        case serviceIcon = "service_icon"
        case url
    }

    // Encodable protocol methods

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: InternalCodingKeys.self)
        try container.encode(serviceLabel, forKey: .serviceLabel)
        try container.encode(serviceIcon, forKey: .serviceIcon)
        try container.encode(url, forKey: .url)
    }
}
