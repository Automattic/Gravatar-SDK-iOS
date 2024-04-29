import Foundation
import Gravatar

extension ImageDownloader {
    @discardableResult
    func fetchImage(
        with url: URL,
        forceRefresh: Bool = false,
        processingMethod: ImageProcessingMethod = .common(),
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
