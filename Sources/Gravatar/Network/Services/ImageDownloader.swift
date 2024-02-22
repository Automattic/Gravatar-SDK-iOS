import Foundation
import UIKit

public typealias ImageDownloadCompletion = ((Result<GravatarImageDownloadResult, GravatarImageDownloadError>) -> Void)

public protocol ImageDownloader {
    func fetchImage(
        with email: String,
        options: GravatarImageDownloadOptions,
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
        options: GravatarImageDownloadOptions
    ) async throws -> GravatarImageDownloadResult

    func fetchImage(
        with url: URL,
        forceRefresh: Bool,
        processingMethod: ImageProcessingMethod
    ) async throws -> GravatarImageDownloadResult
}
