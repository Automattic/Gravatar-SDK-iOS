import Foundation

extension ImageService: ImageDownloader {
    @discardableResult
    public func fetchImage(
        with email: String,
        options: ImageDownloadOptions = ImageDownloadOptions(),
        completionHandler: ImageDownloadCompletion? = nil
    ) -> CancellableDataTask {
        Task {
            do {
                let result = try await fetchImage(with: email, options: options)
                completionHandler?(Result.success(result))
            } catch let error as ImageFetchingError {
                completionHandler?(Result.failure(error))
            } catch {
                completionHandler?(Result.failure(.responseError(reason: .unexpected(error))))
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
            } catch let error as ImageFetchingError {
                completionHandler?(Result.failure(error))
            } catch {
                completionHandler?(Result.failure(.responseError(reason: .unexpected(error))))
            }
        }
    }

    public func fetchImage(
        with email: String,
        options: ImageDownloadOptions = ImageDownloadOptions()
    ) async throws -> ImageDownloadResult {
        guard let gravatarURL = GravatarURL.gravatarUrl(with: email, options: options.imageQueryOptions) else {
            throw ImageFetchingError.requestError(reason: .urlInitializationFailed)
        }

        if !options.forceRefresh, let result = cachedImageResult(for: gravatarURL) {
            return result
        }

        return try await fetchImage(from: gravatarURL, forceRefresh: options.forceRefresh, processor: options.processingMethod.processor)
    }

    public func fetchImage(
        with url: URL,
        forceRefresh: Bool = false,
        processingMethod: ImageProcessingMethod = .common
    ) async throws -> ImageDownloadResult {
        if !forceRefresh, let result = cachedImageResult(for: url) {
            return result
        }
        return try await fetchImage(from: url, forceRefresh: forceRefresh, processor: processingMethod.processor)
    }
}

extension ImageService {
    private func cachedImageResult(for url: URL) -> ImageDownloadResult? {
        guard let cachedImage = imageCache.getImage(forKey: url.absoluteString) else {
            return nil
        }
        return ImageDownloadResult(image: cachedImage, sourceURL: url)
    }
}
