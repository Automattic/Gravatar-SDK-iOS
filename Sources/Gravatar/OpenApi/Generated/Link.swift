import Foundation

/// A link the user has added to their profile.
///
public struct Link: Codable, Hashable, Sendable {
    /// The label for the link.
    public private(set) var label: String
    /// The URL to the link.
    public private(set) var url: String

    @available(*, deprecated, message: "init will become internal on the next release")
    public init(label: String, url: String) {
        self.label = label
        self.url = url
    }

    @available(*, deprecated, message: "CodingKeys will become internal on the next release.")
    public enum CodingKeys: String, CodingKey, CaseIterable {
        case label
        case url
    }

    enum InternalCodingKeys: String, CodingKey, CaseIterable {
        case label
        case url
    }

    // Encodable protocol methods

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: InternalCodingKeys.self)
        try container.encode(label, forKey: .label)
        try container.encode(url, forKey: .url)
    }
}
