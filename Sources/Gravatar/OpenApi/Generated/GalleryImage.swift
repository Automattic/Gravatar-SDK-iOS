import Foundation

/// A gallery image a user has uploaded.
///
public struct GalleryImage: Codable, Hashable, Sendable {
    /// The URL to the image.
    public let url: String

    @available(*, deprecated, message: "init will become internal on the next release")
    public init(url: String) {
        self.url = url
    }

    @available(*, deprecated, message: "CodingKeys will become internal on the next release.")
    public enum CodingKeys: String, CodingKey, CaseIterable {
        case url
    }

    enum InternalCodingKeys: String, CodingKey, CaseIterable {
        case url
    }

    // Encodable protocol methods

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: InternalCodingKeys.self)
        try container.encode(url, forKey: .url)
    }
}
