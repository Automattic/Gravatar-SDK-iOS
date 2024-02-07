import Foundation

public typealias ImageDownloadCompletion = ((Result<GravatarImageDownloadResult, GravatarImageDownloadError>) -> Void)

public protocol ImageServing {
    func retrieveImage(
        with email: String,
        options: GravatarImageDownloadOptions,
        completionHandler: ImageDownloadCompletion?
    ) -> CancellableDataTask

    func retrieveImage(
        with url: URL,
        forceRefresh: Bool,
        processor: GravatarImageProcessor,
        completionHandler: ImageDownloadCompletion?
    ) -> CancellableDataTask?

    func fetchImage(
        with email: String,
        options: GravatarImageDownloadOptions
    ) async throws -> GravatarImageDownloadResult

    func fetchImage(
        with url: URL,
        forceRefresh: Bool,
        processor: GravatarImageProcessor
    ) async throws -> GravatarImageDownloadResult
}
