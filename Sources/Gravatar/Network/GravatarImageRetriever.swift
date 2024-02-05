import Foundation
import UIKit

public typealias ImageDownloadCompletion = ((Result<GravatarImageDownloadResult, GravatarImageDownloadError>) -> Void)

public class GravatarImageRetriever: GravatarImageRetrieverProtocol {
    
    internal let imageCache: GravatarImageCaching
    private let urlSession: URLSessionProtocol
    
    public init(imageCache: GravatarImageCaching = GravatarImageCache.shared, urlSession: URLSessionProtocol = URLSession.shared) {
        self.imageCache = imageCache
        self.urlSession = urlSession
    }
    
    public convenience init() {
        self.init(imageCache: GravatarImageCache.shared, urlSession: URLSession.shared)
    }

    /// Downloads the the avatar image of the given email.
    /// - Parameters:
    ///   - email: Gravatar account email
    ///   - options: Options used while downloading.
    ///   - completionHandler: Completion handler to call when the download is completed.
    /// - Returns: A `CancellableDataTask` to cancel the download.
    @discardableResult
    public func retrieveImage(
        with email: String,
        options: GravatarImageDownloadOptions? = nil,
        completionHandler: ImageDownloadCompletion? = nil
    ) -> CancellableDataTask? {
        let options = options ?? GravatarImageDownloadOptions()
        let size = options.preferredSize ?? GravatarImageDownloadOptions.defaultSize
        let targetSize = max(size.width, size.height) * UIScreen.main.scale
        guard let gravatarURL = GravatarURL.gravatarUrl(for: email, size: Int(targetSize), rating: options.gravatarRating) else {
            completionHandler?(.failure(GravatarImageDownloadError.requestError(reason: .urlInitializationFailed)))
            return nil
        }
        
        return retrieveImage(with: gravatarURL, forceRefresh: options.forceRefresh, processor: options.processor, completionHandler: completionHandler)
    }
    
    /// Downloads the the image from the given url.
    /// - Parameters:
    ///   - url: Image URL
    ///   - forceRefresh: If true ignores the cache and fetches the image from the given URL. Default: false
    ///   - processor: A `GravatarImageProcessor` to use when converting the downloaded `Data` to `UIImage`.
    ///   - completionHandler: Completion handler to call when the download is completed.
    /// - Returns: A `CancellableDataTask` to cancel the download.
    @discardableResult
    public func retrieveImage(
        with url: URL,
        forceRefresh: Bool = false,
        processor: GravatarImageProcessor = DefaultImageProcessor.common,
        completionHandler: ImageDownloadCompletion? = nil
    ) -> CancellableDataTask? {
        let request = request(for: url)
        return retrieveImage(with: request, forceRefresh: forceRefresh, processor: processor,  completionHandler: completionHandler)
    }
    
    /// Downloads the the image with the given `URLRequest`.
    /// - Parameters:
    ///   - request: URLRequest for the image.
    ///   - forceRefresh: If true ignores the cache and fetches the image from the given URL. Default: false
    ///   - processor: A `GravatarImageProcessor` to use when converting the downloaded `Data` to `UIImage`.
    ///   - completionHandler: Completion handler to call when the download is completed.
    /// - Returns: A `CancellableDataTask` to cancel the download.
    @discardableResult
    public func retrieveImage(
        with request: URLRequest,
        forceRefresh: Bool = false,
        processor: GravatarImageProcessor = DefaultImageProcessor.common,
        completionHandler: ImageDownloadCompletion? = nil
    ) -> CancellableDataTask? {
        
        guard let url = request.url else {
            completionHandler?(.failure(GravatarImageDownloadError.requestError(reason: .emptyURL)))
            return nil
        }
        
        // Ignore the cache value if forceRefresh is true
        if !forceRefresh, let cachedImage = imageCache.getImage(forKey: url.absoluteString) {
            completionHandler?(.success(GravatarImageDownloadResult(image: cachedImage, sourceURL: url)))
            return nil
        }
        
        let task = urlSession.dataTask(with: request, completionHandler: { [weak self] data, response, error in
            if let error {
                completionHandler?(.failure(GravatarImageDownloadError.responseError(reason: .URLSessionError(error: error))))
                return
            }
            
            if (response as? HTTPURLResponse)?.statusCode == HTTPStatus.notFound.rawValue {
                completionHandler?(.failure(GravatarImageDownloadError.responseError(reason: .notFound)))
                return
            }
            
            guard let data = data, let image = processor.process(data) else {
                completionHandler?(.failure(GravatarImageDownloadError.responseError(reason: .imageInitializationFailed)))
                return
            }
            
            if response?.url == url {
                self?.imageCache.setImage(image, forKey: url.absoluteString)
                completionHandler?(.success(GravatarImageDownloadResult(image: image, sourceURL: url)))
            }
            else {
                completionHandler?(.failure(GravatarImageDownloadError.responseError(reason: .urlMismatch)))
            }
        })
        
        task.resume()
        return task
    }
    
    private func request(for url: URL) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpShouldHandleCookies = false
        request.addValue("image/*", forHTTPHeaderField: "Accept")
        return request
    }
}
