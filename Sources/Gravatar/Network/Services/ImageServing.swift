import Foundation

public typealias ImageDownloadCompletion = ((Result<GravatarImageDownloadResult, GravatarImageDownloadError>) -> Void)

public protocol ImageServing {
    func fetchImage(
        with email: String,
        options: GravatarImageDownloadOptions,
        completionHandler: ImageDownloadCompletion?
    ) -> CancellableDataTask

    func fetchImage(
        with url: URL,
        forceRefresh: Bool,
        processor: ImageProcessor,
        completionHandler: ImageDownloadCompletion?
    ) -> CancellableDataTask?

    func fetchImage(
        with email: String,
        options: GravatarImageDownloadOptions
    ) async throws -> GravatarImageDownloadResult

    func fetchImage(
        with url: URL,
        forceRefresh: Bool,
        processor: ImageProcessor
    ) async throws -> GravatarImageDownloadResult

    func uploadImage(
        _ image: UIImage,
        accountEmail: String,
        accountToken: String
    ) async throws -> URLResponse

    func uploadImage(
        _ image: UIImage,
        accountEmail: String,
        accountToken: String,
        completion: ((_ error: NSError?) -> Void)?
    )
}
