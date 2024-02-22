import Foundation

extension ImageService: ImageDownloader {
    @discardableResult
    public func fetchImage(
        with email: String,
        options: GravatarImageDownloadOptions = GravatarImageDownloadOptions(),
        completionHandler: ImageDownloadCompletion? = nil
    ) -> CancellableDataTask {
        Task {
            do {
                let result = try await fetchImage(with: email, options: options)
                completionHandler?(Result.success(result))
            } catch let error as GravatarImageDownloadError {
                completionHandler?(Result.failure(error))
            } catch {
                completionHandler?(Result.failure(GravatarImageDownloadError.responseError(reason: .URLSessionError(error: error))))
            }
        }
    }

    @discardableResult
    public func fetchImage(
        with url: URL,
        forceRefresh: Bool = false,
        processingMethod: ImageProcessingMethod = .common,
        completionHandler: ImageDownloadCompletion?
    ) -> CancellableDataTask? {
        Task {
            do {
                let result = try await fetchImage(with: url, forceRefresh: forceRefresh, processingMethod: processingMethod)
                completionHandler?(Result.success(result))
            } catch let error as GravatarImageDownloadError {
                completionHandler?(Result.failure(error))
            } catch {
                completionHandler?(Result.failure(GravatarImageDownloadError.responseError(reason: .URLSessionError(error: error))))
            }
        }
    }

    public func fetchImage(
        with email: String,
        options: GravatarImageDownloadOptions = GravatarImageDownloadOptions()
    ) async throws -> GravatarImageDownloadResult {
        guard let gravatarURL = GravatarURL.gravatarUrl(with: email, options: options) else {
            throw GravatarImageDownloadError.requestError(reason: .urlInitializationFailed)
        }

        if !options.forceRefresh, let result = cachedImageResult(for: gravatarURL) {
            return result
        }

        let (image, url) = try await fetchImage(from: gravatarURL, procressor: options.processingMethod.processor)
        return GravatarImageDownloadResult(image: image, sourceURL: url)
    }

    public func fetchImage(
        with url: URL,
        forceRefresh: Bool = false,
        processingMethod: ImageProcessingMethod = .common
    ) async throws -> GravatarImageDownloadResult {
        if !forceRefresh, let result = cachedImageResult(for: url) {
            return result
        }

        let (image, url) = try await fetchImage(from: url, procressor: processingMethod.processor)
        return GravatarImageDownloadResult(image: image, sourceURL: url)
    }
}

extension ImageService {
    private func cachedImageResult(for url: URL) -> GravatarImageDownloadResult? {
        guard let cachedImage = imageCache.getImage(forKey: url.absoluteString) else {
            return nil
        }
        return GravatarImageDownloadResult(image: cachedImage, sourceURL: url)
    }
}
