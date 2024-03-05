import UIKit

/// Represents a type which can be used by Gravatar to upload an  image to Gravatar.
public protocol ImageUploader {

    /// Uploads an image to be used as the user's Gravatar profile image, and returns the `URLResponse` of the network tasks asynchronously.
    /// - Parameters:
    ///   - image: The image to be uploaded.
    ///   - accountEmail: The user email account.
    ///   - accountToken: The authentication token for the user.
    /// - Returns: An asynchronously-delivered `URLResponse` instance, containing the response of the upload network task.
    func uploadImage(
        _ image: UIImage,
        accountEmail: String,
        accountToken: String
    ) async throws -> URLResponse
    
    /// Uploads an image to be used as the user's Gravatar profile image.
    /// - Parameters:
    ///   - image: The image to be uploaded.
    ///   - accountEmail: The user email account.
    ///   - accountToken: The authentication token for the user.
    ///   - completion: A closure which will be called when the upload network task finishes.
    func uploadImage(
        _ image: UIImage,
        accountEmail: String,
        accountToken: String,
        completion: ((_ error: ImageUploadError?) -> Void)?
    )
}
