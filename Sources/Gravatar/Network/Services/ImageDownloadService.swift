import UIKit

/// A service to perform image downloading.
///
/// This is the default type which implements ``ImageDownloader``..
/// Unless specified otherwise, `ImageDownloadService` will use a `URLSession` based `HTTPClient`, and a in-memory image cache.
public actor ImageDownloadService: ImageDownloader {
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

        await imageCache.setEntry(.inProgress(task), for: url.absoluteString)

        let image = try await getImage(from: task)
        await imageCache.setEntry(.ready(image), for: url.absoluteString)
        return ImageDownloadResult(image: image, sourceURL: url)
    }

    public func fetchImage(
        with url: URL,
        forceRefresh: Bool = false,
        processingMethod: ImageProcessingMethod = .common
    ) async throws -> ImageDownloadResult {
        if !forceRefresh, let image = try await cachedImage(for: url) {
            return ImageDownloadResult(image: image, sourceURL: url)
        }
        return try await fetchImage(from: url, forceRefresh: forceRefresh, processor: processingMethod.processor)
    }

    func cachedImage(for url: URL) async throws -> UIImage? {
        guard let entry = await imageCache.getEntry(with: url.absoluteString) else {
            return nil
        }

        switch entry {
        case .inProgress(let task):
            return try await getImage(from: task)
        case .ready(let image):
            return image
        }
    }

    func getImage(from task: Task<UIImage, Error>) async throws -> UIImage {
        do {
            let image = try await task.value
            return image
        } catch let error as HTTPClientError {
            throw ImageFetchingError.responseError(reason: error.map())
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
