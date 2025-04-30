import Foundation

public typealias ImageID = String

public protocol AvatarDetails: Sendable {
    /// Unique identifier for the image.
    var imageID: ImageID { get }
    /// Image URL
    var imageURL: String { get }
    /// Rating associated with the image.
    var imageRating: Rating { get }
    /// Alternative text description of the image.
    var altText: String { get }
    /// Whether the image is currently selected as the provided selected email's avatar.
    var selected: Bool? { get }
    /// Date and time when the image was last updated.
    var updatedDate: Date { get }
}

extension AvatarDetails {
    package func url(withSize size: String) -> String {
        if let newURL = URLComponents(string: imageURL)?.replacingQueryItem(name: "size", value: size).string {
            return newURL
        }
        return imageURL
    }

    package var isSelected: Bool {
        selected ?? false
    }
}
