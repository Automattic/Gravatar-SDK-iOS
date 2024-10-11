import Foundation

/// A gallery image a user has uploaded.
///
public struct GalleryImage: Codable, Hashable, Sendable {
    /// The URL to the image.
    public private(set) var url: String
    /// The image alt text.
    public private(set) var altText: String?

    init(url: String, altText: String? = nil) {
        self.url = url
        self.altText = altText
    }

    enum CodingKeys: String, CodingKey, CaseIterable {
        case url
        case altText = "alt_text"
    }

    // Encodable protocol methods

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(url, forKey: .url)
        try container.encodeIfPresent(altText, forKey: .altText)
    }
}
