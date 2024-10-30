import UIKit

/// A service to perform image downloading.
///
/// This is the default type which implements ``ImageDownloader``.
public actor ImageDownloadService: ImageDownloader, Sendable {
    private let client: HTTPClient
    let imageCache: ImageCaching

    /// Creates a new `ImageDownloadService`
    /// - Parameters:
    ///   - urlSession: Manages the network tasks. It can be a [URLSession] or any other type that conforms to ``URLSessionProtocol``.
    /// If not provided, a properly configured [URLSession] is used.
    ///   - cache: An image cache of type ``ImageCaching``. If not provided, it defaults to SDK's in-memory cache.
    ///
    /// [URLSession]: https://developer.apple.com/documentation/foundation/urlsession
    public init(urlSession: URLSessionProtocol? = nil, cache: ImageCaching? = nil) {
        self.client = URLSessionHTTPClient(urlSession: urlSession)
        self.imageCache = cache ?? ImageCache.shared
    }

    public func fetchImage(with url: URL, forceRefresh: Bool = false, processingMethod: ImageProcessingMethod = .common()) async throws -> ImageDownloadResult {
        let request = URLRequest.imageRequest(url: url, forceRefresh: forceRefresh)

        if !forceRefresh, let image = try await cachedImage(for: url) {
            try Task.checkCancellation()
            return ImageDownloadResult(image: image, sourceURL: url)
        }

        let task = Task<UIImage, Error> {
            try await fetchAndProcessImage(request: request, processor: processingMethod.processor)
        }

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
            try Task.checkCancellation()
            return image
        case .ready(let image):
            return image
        }
    }

    private func awaitAndCacheImage(from task: Task<UIImage, Error>, cacheKey key: String) async throws -> UIImage {
        let image: UIImage
        do {
            image = try await task.value
            try Task.checkCancellation()
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
            try Task.checkCancellation()
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
        var request = forceRefresh ? URLRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData) : URLRequest(url: url)
        if forceRefresh, let url = request.url, url.isGravatarURL {
            var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false)
            // Gravatar doesn't support cache control headers. So we add a random query parameter to
            // bypass the backend cache and get the latest image.
            // Remove this if Gravatar starts to support cache control headers.
            urlComponents?.queryItems?.append(.init(name: "_", value: "\(NSDate().timeIntervalSince1970)"))
            request.url = urlComponents?.url
        }
        request.httpShouldHandleCookies = false
        request.addValue("image/*", forHTTPHeaderField: "Accept")
        return request
    }
}
