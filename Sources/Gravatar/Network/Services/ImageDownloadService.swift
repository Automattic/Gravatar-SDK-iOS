import UIKit

/// A service to perform image downloading.
///
/// This is the default type which implements ``ImageDownloader``..
/// Unless specified otherwise, `ImageDownloadService` will use a `URLSession` based `HTTPClient`, and a in-memory image cache.
public actor ImageDownloadService: ImageDownloader, Sendable {
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
        self.imageCache = cache ?? ImageCache.shared
    }

    public init(urlSession: URLSession, cache: ImageCaching? = nil) {
        self.client = URLSessionHTTPClient(urlSession: urlSession)
        self.imageCache = cache ?? ImageCache.shared
    }

    public func fetchImage(with url: URL, forceRefresh: Bool = false, processingMethod: ImageProcessingMethod = .common()) async throws -> ImageDownloadResult {
        let request = URLRequest.imageRequest(url: url, forceRefresh: forceRefresh)

        if !forceRefresh, let image = try await cachedImage(for: url) {
            return ImageDownloadResult(image: image, sourceURL: url)
        }
        let task = Task<UIImage, Error> {
            try await fetchAndProcessImage(request: request, processor: processingMethod.processor)
        }
        try Task.checkCancellation()
        // Create `.inProgress` entry before we await to prevent re-entrancy issues
        let cacheKey = url.absoluteString
        imageCache.setEntry(.inProgress(task), for: cacheKey)
        let image = try await awaitAndCacheImage(from: task, cacheKey: cacheKey)
        try Task.checkCancellation()
        return ImageDownloadResult(image: image, sourceURL: url)
    }

    private func cachedImage(for url: URL) async throws -> UIImage? {
        guard let entry = imageCache.getEntry(with: url.absoluteString) else { return nil }
        switch entry {
        case .inProgress(let task):
            let image = try await task.value
            return image
        case .ready(let image):
            return image
        }
    }

    private func awaitAndCacheImage(from task: Task<UIImage, Error>, cacheKey key: String) async throws -> UIImage {
        let image: UIImage
        do {
            image = try await task.value
        } catch {
            imageCache.setEntry(nil, for: key)
            throw error
        }
        imageCache.setEntry(.ready(image), for: key)
        return image
    }

    private func fetchAndProcessImage(request: URLRequest, processor: ImageProcessor) async throws -> UIImage {
        do {
            let (data, _) = try await client.fetchData(with: request)
            guard let image = processor.process(data) else {
                throw ImageFetchingError.imageProcessorFailed
            }
            return image
        } catch let error as HTTPClientError {
            throw ImageFetchingError.responseError(reason: error.map())
        } catch let error as ImageFetchingError {
            throw error
        } catch {
            throw ImageFetchingError.responseError(reason: .unexpected(error))
        }
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
