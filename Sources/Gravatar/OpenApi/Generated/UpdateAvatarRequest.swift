import Foundation

/// The avatar data to update. Partial updates are supported, so only the provided fields will be updated.
///
struct UpdateAvatarRequest: Codable, Hashable, Sendable {
    /// Rating associated with the image.
    private(set) var rating: AvatarRating?
    /// Alternative text description of the image.
    private(set) var altText: String?

    init(rating: AvatarRating? = nil, altText: String? = nil) {
        self.rating = rating
        self.altText = altText
    }

    enum CodingKeys: String, CodingKey, CaseIterable {
        case rating
        case altText = "alt_text"
    }

    // Encodable protocol methods

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(rating, forKey: .rating)
        try container.encodeIfPresent(altText, forKey: .altText)
    }
}
