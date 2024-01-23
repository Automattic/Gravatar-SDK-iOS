//
//  GravatarNetworkManager.swift
//
//
//  Created by Pinar Olguc on 18.01.2024.
//

import Foundation
import UIKit

public class GravatarNetworkManager {

    private let imageCache: GravatarImageCaching
    private let urlSession: URLSession

    init(imageCache: GravatarImageCaching, urlSession: URLSession) {
        self.imageCache = imageCache
        self.urlSession = urlSession
    }

    convenience init() {
        self.init(imageCache: GravatarImageCache.shared, urlSession: URLSession.shared)
    }

    public func retrieveImage(
        with email: String,
        options: GravatarDownloadOptions? = nil,
        completionHandler: ((Result<GravatarImageDownloadResult, GravatarError>) -> Void)? = nil) -> CancellableDataTask? {
        let options = options ?? GravatarDownloadOptions(options: [])
        let size = options.preferredSize ?? GravatarDownloadOptions.defaultSize
        let targetSize = max(size.width, size.height) * UIScreen.main.scale
        guard let gravatarURL = Gravatar.gravatarUrl(for: email, size: Int(targetSize), rating: options.gravatarRating) else {
            completionHandler?(.failure(GravatarError.requestError(reason: .emptyURL)))
            return nil
        }

        return retrieveImage(with: gravatarURL, options: options, completionHandler: completionHandler)
    }

    public func retrieveImage(
        with url: URL,
        options: GravatarDownloadOptions? = nil,
        completionHandler: ((Result<GravatarImageDownloadResult, GravatarError>) -> Void)? = nil
    ) -> CancellableDataTask? {
        let options = options ?? GravatarDownloadOptions(options: [])

        // Ignore the cache value if forceRefresh is true
        if !options.forceRefresh, let cachedImage = imageCache.getImage(forKey: url.absoluteString) {
            completionHandler?(.success(GravatarImageDownloadResult(image: cachedImage, sourceURL: url)))
            return nil
        }

        let request = request(for: url)

        let task = urlSession.dataTask(with: request, completionHandler: { [weak self] data, response, error in
            if let error {
                completionHandler?(.failure(.responseError(reason: .URLSessionError(error: error))))
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
