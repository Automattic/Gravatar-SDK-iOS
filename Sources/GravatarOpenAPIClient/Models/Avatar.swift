import Foundation

/// An avatar that the user has already uploaded to their Gravatar account.
///
public struct Avatar: Codable, Hashable, Sendable {
    public enum Rating: String, Codable, CaseIterable, Sendable {
        case g = "G"
        case pg = "PG"
        case r = "R"
        case x = "X"
    }

    /// Unique identifier for the image.
    public private(set) var imageId: String
    /// Image URL
    public private(set) var imageUrl: String
    /// Rating associated with the image.
    public private(set) var rating: Rating
    /// Date and time when the image was last updated.
    public private(set) var updatedDate: Date
    /// Alternative text description of the image.
    public private(set) var altText: String
    /// Whether the image is currently selected as the provided selected email's avatar.
    public private(set) var selected: Bool?

    init(imageId: String, imageUrl: String, rating: Rating, updatedDate: Date, altText: String, selected: Bool? = nil) {
        self.imageId = imageId
        self.imageUrl = imageUrl
        self.rating = rating
        self.updatedDate = updatedDate
        self.altText = altText
        self.selected = selected
    }

    enum CodingKeys: String, CodingKey, CaseIterable {
        case imageId = "image_id"
        case imageUrl = "image_url"
        case rating
        case updatedDate = "updated_date"
        case altText = "alt_text"
        case selected
    }

    // Encodable protocol methods

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(imageId, forKey: .imageId)
        try container.encode(imageUrl, forKey: .imageUrl)
        try container.encode(rating, forKey: .rating)
        try container.encode(updatedDate, forKey: .updatedDate)
        try container.encode(altText, forKey: .altText)
        try container.encodeIfPresent(selected, forKey: .selected)
    }
}
