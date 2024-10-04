import Foundation

/// An avatar that the user has already uploaded to their Gravatar account.
///
package struct Avatar: Codable, Hashable, Sendable {
    package enum Rating: String, Codable, CaseIterable, Sendable {
        case g = "G"
        case pg = "PG"
        case r = "R"
        case x = "X"
    }

    /// Unique identifier for the image.
    package private(set) var imageId: String
    /// Image URL
    package private(set) var imageUrl: String
    /// Rating associated with the image.
    package private(set) var rating: Rating
    /// Date and time when the image was last updated.
    package private(set) var updatedDate: Date
    /// Alternative text description of the image.
    package private(set) var altText: String
    /// Whether the image is currently selected as the provided selected email's avatar.
    package private(set) var selected: Bool?

    @available(*, deprecated, message: "init will become internal on the next release")
    package init(imageId: String, imageUrl: String, rating: Rating, updatedDate: Date, altText: String, selected: Bool? = nil) {
        self.imageId = imageId
        self.imageUrl = imageUrl
        self.rating = rating
        self.updatedDate = updatedDate
        self.altText = altText
        self.selected = selected
    }

    @available(*, deprecated, message: "CodingKeys will become internal on the next release.")
    package enum CodingKeys: String, CodingKey, CaseIterable {
        case imageId = "image_id"
        case imageUrl = "image_url"
        case rating
        case updatedDate = "updated_date"
        case altText = "alt_text"
        case selected
    }

    enum InternalCodingKeys: String, CodingKey, CaseIterable {
        case imageId = "image_id"
        case imageUrl = "image_url"
        case rating
        case updatedDate = "updated_date"
        case altText = "alt_text"
        case selected
    }

    // Encodable protocol methods

    package func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: InternalCodingKeys.self)
        try container.encode(imageId, forKey: .imageId)
        try container.encode(imageUrl, forKey: .imageUrl)
        try container.encode(rating, forKey: .rating)
        try container.encode(updatedDate, forKey: .updatedDate)
        try container.encode(altText, forKey: .altText)
        try container.encodeIfPresent(selected, forKey: .selected)
    }

    // Decodable protocol methods

    package init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: InternalCodingKeys.self)

        imageId = try container.decode(String.self, forKey: .imageId)
        imageUrl = try container.decode(String.self, forKey: .imageUrl)
        rating = try container.decode(Rating.self, forKey: .rating)
        updatedDate = try container.decode(Date.self, forKey: .updatedDate)
        altText = try container.decode(String.self, forKey: .altText)
        selected = try container.decodeIfPresent(Bool.self, forKey: .selected)
    }
}
