import UIKit

typealias HTTPHeaderField = (name: String, value: String)

/// Represents a type which can be used by Gravatar to upload an  image to Gravatar.
protocol ImageUploader: Sendable {
    /// Uploads an image to be used as the user's Gravatar profile image, and returns the `URLResponse` of the network tasks asynchronously. Throws
    /// `ImageUploadError`.
    /// - Parameters:
    ///   - image: The image to be uploaded.
    ///   - email: The user email account.
    ///   - accessToken: The authentication token for the user.
    ///   - avatarSelection: How to handle avatar selection after uploading a new avatar
    ///   - additionalHTTPHeaders: Additional headers to add.
    /// - Returns: An asynchronously-delivered `URLResponse` instance, containing the response of the upload network task.
    @discardableResult
    func uploadImage(
        _ image: UIImage,
        accessToken: String,
        avatarSelection: AvatarSelection,
        additionalHTTPHeaders: [HTTPHeaderField]?
    ) async throws -> (data: Data, response: HTTPURLResponse)
}
