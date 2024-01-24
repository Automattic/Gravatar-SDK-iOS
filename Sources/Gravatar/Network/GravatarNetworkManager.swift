import Foundation
import UIKit

public typealias ImageDownloadCompletion = ((Result<GravatarImageDownloadResult, GravatarImageDownloadError>) -> Void)

public class GravatarNetworkManager {

    private let imageCache: GravatarImageCaching
    private let urlSession: URLSession

    public init(imageCache: GravatarImageCaching, urlSession: URLSession) {
        self.imageCache = imageCache
        self.urlSession = urlSession
    }

    public convenience init() {
        self.init(imageCache: GravatarImageCache.shared, urlSession: URLSession.shared)
    }

    @discardableResult
    public func retrieveImage(
        with email: String,
        options: GravatarImageDownloadOptions? = nil,
        completionHandler: ImageDownloadCompletion? = nil) -> CancellableDataTask? {
        let options = options ?? GravatarImageDownloadOptions()
        let size = options.preferredSize ?? GravatarImageDownloadOptions.defaultSize
        let targetSize = max(size.width, size.height) * UIScreen.main.scale
        guard let gravatarURL = GravatarURL.gravatarUrl(for: email, size: Int(targetSize), rating: options.gravatarRating) else {
            completionHandler?(.failure(GravatarImageDownloadError.requestError(reason: .urlInitializationFailed)))
            return nil
        }

        return retrieveImage(with: gravatarURL, options: options, completionHandler: completionHandler)
    }

    @discardableResult
    public func retrieveImage(
        with url: URL,
        options: GravatarImageDownloadOptions? = nil,
        completionHandler: ImageDownloadCompletion? = nil
    ) -> CancellableDataTask? {
        let options = options ?? GravatarImageDownloadOptions()
        let request = request(for: url)
        return retrieveImage(with: request, options: options, completionHandler: completionHandler)
    }
    
    @discardableResult
    public func retrieveImage(
        with request: URLRequest,
        options: GravatarImageDownloadOptions? = nil,
        completionHandler: ImageDownloadCompletion? = nil
    ) -> CancellableDataTask? {
        let options = options ?? GravatarImageDownloadOptions()
        
        guard let url = request.url else {
            completionHandler?(.failure(GravatarImageDownloadError.requestError(reason: .emptyURL)))
            return nil
        }
        
        // Ignore the cache value if forceRefresh is true
        if !options.forceRefresh, let cachedImage = imageCache.getImage(forKey: url.absoluteString) {
            completionHandler?(.success(GravatarImageDownloadResult(image: cachedImage, sourceURL: url)))
            return nil
        }
        
        let task = urlSession.dataTask(with: request, completionHandler: { [weak self] data, response, error in
            if let error {
                completionHandler?(.failure(.responseError(reason: .URLSessionError(error: error))))
                return
            }
            
            if (response as? HTTPURLResponse)?.statusCode == HTTPStatus.notFound.rawValue {
                completionHandler?(.failure(.responseError(reason: .notFound)))
                return
            }
            
            guard let data = data, let image = options.processor.process(data, options: options) else {
                completionHandler?(.failure(.responseError(reason: .imageInitializationFailed)))
                return
            }

            if response?.url == url {
                self?.imageCache.setImage(image, forKey: url.absoluteString)
                completionHandler?(.success(GravatarImageDownloadResult(image: image, sourceURL: url)))
            }
            else {
                completionHandler?(.failure(.responseError(reason: .urlMismatch)))
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
