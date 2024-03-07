import Foundation
import UIKit

public typealias ImageDownloadCompletion = (Result<ImageDownloadResult, ImageFetchingError>) -> Void

public protocol ImageDownloader {
    func fetchImage(
        with email: String,
        options: ImageDownloadOptions,
        completionHandler: ImageDownloadCompletion?
    ) -> CancellableDataTask

    func fetchImage(
        with url: URL,
        forceRefresh: Bool,
        processingMethod: ImageProcessingMethod,
        completionHandler: ImageDownloadCompletion?
    ) -> CancellableDataTask?

    func fetchImage(
        with email: String,
        options: ImageDownloadOptions
    ) async throws -> ImageDownloadResult

    func fetchImage(
        with url: URL,
        forceRefresh: Bool,
        processingMethod: ImageProcessingMethod
    ) async throws -> ImageDownloadResult
}
