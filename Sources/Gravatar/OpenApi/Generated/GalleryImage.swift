import Foundation

/// A gallery image a user has uploaded.
///
public struct GalleryImage: Codable, Hashable, Sendable {
    /// The URL to the image.
    public private(set) var url: String
    /// The image alt text.
    public private(set) var altText: String?

    @available(*, deprecated, message: "init will become internal on the next release")
    public init(url: String) {
        self.url = url
    }

    // NOTE: This init is maintained manually.
    // Avoid deleting this init until the deprecation of is applied.
    init(url: String, altText: String? = nil) {
        self.url = url
        self.altText = altText
    }

    @available(*, deprecated, message: "CodingKeys will become internal on the next release.")
    public enum CodingKeys: String, CodingKey, CaseIterable {
        case url
    }

    enum InternalCodingKeys: String, CodingKey, CaseIterable {
        case url
        case altText = "alt_text"
    }

    // Encodable protocol methods

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: InternalCodingKeys.self)
        try container.encode(url, forKey: .url)
        try container.encodeIfPresent(altText, forKey: .altText)
    }

    // Decodable protocol methods

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: InternalCodingKeys.self)

        url = try container.decode(String.self, forKey: .url)
        altText = try container.decodeIfPresent(String.self, forKey: .altText)
    }
}
