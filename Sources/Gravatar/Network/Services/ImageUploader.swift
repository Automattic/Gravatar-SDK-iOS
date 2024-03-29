import UIKit

/// Represents a type which can be used by Gravatar to upload an  image to Gravatar.
protocol ImageUploader {
    /// Uploads an image to be used as the user's Gravatar profile image, and returns the `URLResponse` of the network tasks asynchronously. Throws
    /// `ImageUploadError`.
    /// - Parameters:
    ///   - image: The image to be uploaded.
    ///   - email: The user email account.
    ///   - accessToken: The authentication token for the user.
    /// - Returns: An asynchronously-delivered `URLResponse` instance, containing the response of the upload network task.
    @discardableResult
    func uploadImage(
        _ image: UIImage,
        email: Email,
        accessToken: String
    ) async throws -> URLResponse
}
