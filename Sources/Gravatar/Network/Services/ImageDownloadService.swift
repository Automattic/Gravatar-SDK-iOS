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

    public func fetchImage(with url: URL, forceRefresh: Bool = false, processingMethod: ImageProcessingMethod = .common()) async throws -> ImageDownloadResult {
        let request = URLRequest.imageRequest(url: url, forceRefresh: forceRefresh)

        if !forceRefresh, let entry = await imageCache.getEntry(with: url.absoluteString) {
            switch entry {
            case .inProgress(let task):
                let image = try await task.value
                return ImageDownloadResult(image: image, sourceURL: url)
            case .ready(let image):
                return ImageDownloadResult(image: image, sourceURL: url)
            }
        }
        let task = Task<UIImage, Error> {
            try await fetchAndProcessImage(request: request, processor: processingMethod.processor)
        }
        await imageCache.setEntry(.inProgress(task), for: url.absoluteString)
        let image: UIImage
        do {
            image = try await task.value
        } catch {
            await imageCache.setEntry(nil, for: url.absoluteString)
            throw error
        }
        await imageCache.setEntry(.ready(image), for: url.absoluteString)
        return ImageDownloadResult(image: image, sourceURL: url)
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

    public func cancelTask(for url: URL) async {
        if let entry = await imageCache.getEntry(with: url.absoluteString) {
            switch entry {
            case .inProgress(let task):
                if !task.isCancelled {
                    task.cancel()
                }
            default:
                break
            }
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
