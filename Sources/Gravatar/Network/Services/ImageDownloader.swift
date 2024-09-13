import Foundation
import UIKit

/// Represents a type which can be used by Gravatar to fetch images.
public protocol ImageDownloader: Sendable {
    /// Fetches an image from the given `URL`, and delivers the image asynchronously. Throws `ImageFetchingError`.
    /// - Parameters:
    ///   - url: The URL from where to download the image.
    ///   - forceRefresh: Force the image to be downloaded, ignoring the cache.
    ///   - processingMethod: Method to use for processing the downloaded `Data`.
    /// - Returns: An asynchronously-delivered Result type containing the image and its URL.
    func fetchImage(
        with url: URL,
        forceRefresh: Bool,
        processingMethod: ImageProcessingMethod
    ) async throws -> ImageDownloadResult

    /// Cancels the download task for the given `URL`.
    /// - Parameter url: `URL` of the download task.
    func cancelTask(for url: URL)
}
