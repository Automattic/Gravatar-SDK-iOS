import Foundation

/// A gallery image a user has uploaded.
///
public struct GalleryImage: Codable, Hashable, Sendable {
    /// The URL to the image.
    public private(set) var url: String

    public init(url: String) {
        self.url = url
    }

    public enum CodingKeys: String, CodingKey, CaseIterable {
        case url
    }

    // Encodable protocol methods

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(url, forKey: .url)
    }
}
