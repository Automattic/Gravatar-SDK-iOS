import Foundation
import UIKit

/// A service to perform uploading and downloading of avatars.
///
/// An avatar is a profile image of a Gravatar user. See [the avatar docs](https://support.gravatar.com/profiles/avatars/) for more info.
public struct AvatarService: Sendable {
    private let imageDownloader: ImageDownloader
    private let imageUploader: ImageUploader

    /// Creates a new `AvatarService`
    ///
    /// Optionally, you can pass a custom type conforming to ``HTTPClient`` to gain control over networking tasks.
    /// Similarly, you can pass a custom type conforming to ``ImageCaching`` to use your custom caching system.
    /// - Parameters:
    ///   - client: A type which will perform basic networking operations.
    ///   - cache: A type which will perform image caching operations.
    public init(client: HTTPClient? = nil, cache: ImageCaching? = nil) {
        self.imageDownloader = ImageDownloadService(client: client, cache: cache)
        self.imageUploader = ImageUploadService(client: client)
    }

    /// Fetches a Gravatar user profile image using an `AvatarId`, and delivers the image asynchronously. See also: ``ImageDownloadService`` to
    /// download the avatar via URL.
    /// - Parameters:
    ///   - avatarID: An `AvatarIdentifier` for the gravatar account
    ///   - options: The options needed to perform the download.
    /// - Returns: An asynchronously-delivered Result type containing the image and its URL.
    public func fetch(
        with avatarID: AvatarIdentifier,
        options: ImageDownloadOptions = ImageDownloadOptions()
    ) async throws -> ImageDownloadResult {
        guard let gravatarURL = AvatarURL(with: avatarID, options: options.avatarQueryOptions)?.url else {
            throw ImageFetchingError.requestError(reason: .urlInitializationFailed)
        }

        return try await imageDownloader.fetchImage(with: gravatarURL, forceRefresh: options.forceRefresh, processingMethod: options.processingMethod)
    }

    /// Uploads an image to be used as the user's Gravatar profile image, and returns the `URLResponse` of the network tasks asynchronously. Throws
    /// ``ImageUploadError``.
    /// - Parameters:
    ///   - image: The image to be uploaded.
    ///   - email: An`Email` object
    ///   - accessToken: The authentication token for the user. This is a WordPress.com OAuth2 access token.
    /// - Returns: An asynchronously-delivered `URLResponse` instance, containing the response of the upload network task.
    @discardableResult
    @available(*, deprecated, renamed: "upload(_:accessToken:)")
    public func upload(_ image: UIImage, email: Email, accessToken: String) async throws -> URLResponse {
        try await imageUploader.uploadImage(image, accessToken: accessToken, additionalHTTPHeaders: [(name: "Client-Type", value: "ios")]).response
    }

    /// Uploads an image to be used as the user's Gravatar profile image, and returns the `URLResponse` of the network tasks asynchronously. Throws
    /// ``ImageUploadError``.
    /// - Parameters:
    ///   - image: The image to be uploaded.
    ///   - accessToken: The authentication token for the user. This is a WordPress.com OAuth2 access token.
    /// - Returns: An asynchronously-delivered `AvatarModel` instance, containing data of the newly created avatar.
    @discardableResult
    public func upload(_ image: UIImage, accessToken: String) async throws -> Avatar {
        do {
            let (data, _) = try await imageUploader.uploadImage(image, accessToken: accessToken, additionalHTTPHeaders: [(name: "Client-Type", value: "ios")])
            return try data.decode()

        } catch ImageUploadError.responseError(reason: let reason) where reason.httpStatusCode == 400 {
            guard let data = reason.errorData, let error: ModelError = try? data.decode() else {
                throw ImageUploadError.responseError(reason: reason)
            }
            throw error
        } catch let error as DecodingError {
            throw ImageUploadError.responseError(reason: .unexpected(error))
        } catch {
            throw error
        }
    }
}

extension ModelError: Error {}
