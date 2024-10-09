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
    /// Optionally, you can pass a custom type conforming to ``URLSessionProtocol``.
    /// Similarly, you can pass a custom type conforming to ``ImageCaching`` to use your custom caching system.
    /// - Parameters:
    ///   - session: A type which will perform basic networking operations. By default, a properly configured URLSession instance will be used.
    ///   - cache: An image cache of type ``ImageCaching``. If not provided, it defaults to SDK's in-memory cache.
    public init(urlSession: URLSessionProtocol? = nil, cache: ImageCaching? = nil) {
        self.imageDownloader = ImageDownloadService(urlSession: urlSession, cache: cache)
        self.imageUploader = ImageUploadService(urlSession: urlSession)
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
    ///   - accessToken: The authentication token for the user. This is a WordPress.com OAuth2 access token.
    /// - Returns: An asynchronously-delivered `AvatarType` instance, containing data of the newly created avatar.
    @discardableResult
    public func upload(_ image: UIImage, accessToken: String) async throws -> AvatarType {
        let avatar: Avatar = try await upload(image, accessToken: accessToken)
        return avatar
    }

    /// Uploads an image to be used as the user's Gravatar profile image, and returns the `URLResponse` of the network tasks asynchronously. Throws
    /// ``ImageUploadError``.
    /// - Parameters:
    ///   - image: The image to be uploaded.
    ///   - accessToken: The authentication token for the user. This is a WordPress.com OAuth2 access token.
    /// - Returns: An asynchronously-delivered `Avatar` instance, containing data of the newly created avatar.
    @discardableResult
    func upload(_ image: UIImage, accessToken: String) async throws -> Avatar {
        do {
            let (data, _) = try await imageUploader.uploadImage(image, accessToken: accessToken, additionalHTTPHeaders: nil)
            return try data.decode()
        } catch let error as ImageUploadError {
            throw error
        } catch {
            throw ImageUploadError.responseError(reason: .unexpected(error))
        }
    }
}
