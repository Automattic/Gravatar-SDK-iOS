import Foundation
import UIKit

public typealias ImageDownloadCompletion = (Result<ImageDownloadResult, ImageFetchingError>) -> Void

/// Represents a type which can be used by Gravatar to fetch images.
public protocol ImageDownloader {
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
}

extension ImageDownloader {
    @discardableResult
    func fetchImage(
        with url: URL,
        forceRefresh: Bool = false,
        processingMethod: ImageProcessingMethod = .common,
        completionHandler: ImageDownloadCompletion?
    ) -> CancellableDataTask? {
        Task {
            do {
                let result = try await fetchImage(with: url, forceRefresh: forceRefresh, processingMethod: processingMethod)
                completionHandler?(Result.success(result))
            } catch let error as ImageFetchingError {
                completionHandler?(Result.failure(error))
            } catch {
                completionHandler?(Result.failure(.responseError(reason: .unexpected(error))))
            }
        }
    }
}
