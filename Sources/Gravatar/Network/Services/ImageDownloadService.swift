import UIKit

/// A service to perform image downloading.
///
/// This is the default type which implements ``ImageDownloader``..
/// Unless specified otherwise, `ImageDownloadService` will use a `URLSession` based `HTTPClient`, and a in-memory image cache.
public struct ImageDownloadService: ImageDownloader, Sendable {
    private let client: HTTPClient
    let imageCache: ImageCaching

    /// Creates a new `ImageDownloadService`
    ///
    /// Optionally, you can pass a custom type conforming to ``HTTPClient`` to gain control over networking tasks.
    /// Similarly, you can pass a custom type conforming to ``ImageCaching`` to use your custom caching system.
    /// - Parameters:
    ///   - client: A type which will perform basic networking operations.
    ///   - cache: A type which will perform image caching operations.
    public init(client: HTTPClient? = nil, cache: ImageCaching? = nil) {
        self.client = client ?? URLSessionHTTPClient()
        self.imageCache = cache ?? ImageCache()
    }

    private func fetchImage(from url: URL, forceRefresh: Bool, processor: ImageProcessor) async throws -> ImageDownloadResult {
        let request = URLRequest.imageRequest(url: url, forceRefresh: forceRefresh)
        let task = Task<UIImage, Error> {
            let (data, _) = try await self.client.fetchData(with: request)
            guard let image = processor.process(data) else {
                throw ImageFetchingError.imageProcessorFailed
            }
            return image
        }

        await imageCache.setTask(task, for: url)
        do {
            let image = try await task.value
            await imageCache.setImage(image, for: url)
            return ImageDownloadResult(image: image, sourceURL: url)
        } catch let error as HTTPClientError {
            throw ImageFetchingError.responseError(reason: error.map())
        } catch {
            throw ImageFetchingError.responseError(reason: .unexpected(error))
        }
    }

    public func fetchImage(
        with url: URL,
        forceRefresh: Bool = false,
        processingMethod: ImageProcessingMethod = .common
    ) async throws -> ImageDownloadResult {
        if !forceRefresh, let result = try await cachedImageResult(for: url) {
            return result
        }
        return try await fetchImage(from: url, forceRefresh: forceRefresh, processor: processingMethod.processor)
    }

    func cachedImageResult(for url: URL) async throws -> ImageDownloadResult? {
        guard let image = try await imageCache.getImage(for: url) else {
            return nil
        }

        return ImageDownloadResult(image: image, sourceURL: url)
    }
}

extension URLRequest {
    fileprivate static func imageRequest(url: URL, forceRefresh: Bool) -> URLRequest {
        var request = forceRefresh ? URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData) : URLRequest(url: url)
        request.httpShouldHandleCookies = false
        request.addValue("image/*", forHTTPHeaderField: "Accept")
        return request
    }
}
