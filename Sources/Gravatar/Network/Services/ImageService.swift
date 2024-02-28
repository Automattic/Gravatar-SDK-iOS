import UIKit

public struct ImageService: ImageServing {
    private let client: HTTPClient
    private let imageCache: ImageCaching

    public init(client: HTTPClient? = nil, cache: ImageCaching? = nil) {
        self.client = client ?? URLSessionHTTPClient()
        self.imageCache = cache ?? ImageCache()
    }

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
        options: GravatarImageDownloadOptions = GravatarImageDownloadOptions()
    ) async throws -> GravatarImageDownloadResult {
        guard let gravatarURL = GravatarURL.gravatarUrl(with: email, options: options) else {
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
    ) async throws -> GravatarImageDownloadResult {
        if !forceRefresh, let result = cachedImageResult(for: url) {
            return result
        }
        return try await fetchImage(from: url, forceRefresh: forceRefresh, processor: processingMethod.processor)
    }

    private func fetchImage(from url: URL, forceRefresh: Bool, processor: ImageProcessor) async throws -> GravatarImageDownloadResult {
        let request = URLRequest.imageRequest(url: url, forceRefresh: forceRefresh)
        do {
            let (data, _) = try await client.fetchData(with: request)
            guard let image = processor.process(data) else {
                throw ImageFetchingError.imageProcessorFailed
            }
            imageCache.setImage(image, forKey: url.absoluteString)
            return GravatarImageDownloadResult(image: image, sourceURL: url)
        } catch let error as HTTPClientError {
            throw ImageFetchingError.responseError(reason: error.map())
        } catch {
            throw ImageFetchingError.responseError(reason: .unexpected(error))
        }
    }

    @discardableResult
    public func uploadImage(_ image: UIImage, accountEmail: String, accountToken: String) async throws -> URLResponse {
        guard let data = image.pngData() else {
            throw ImageUploadError.cannotConvertImageIntoData
        }

        let boundary = "Boundary-\(UUID().uuidString)"
        let request = URLRequest.imageUploadRequest(with: boundary).settingAuthorizationHeaderField(with: accountToken)
        let body = imageUploadBody(with: data, account: accountEmail, boundary: boundary)
        do {
            let response = try await client.uploadData(with: request, data: body)
            return response
        } catch let error as HTTPClientError {
            throw ImageUploadError.responseError(reason: error.map())
        } catch {
            throw ImageUploadError.responseError(reason: .unexpected(error))
        }
    }

    public func uploadImage(_ image: UIImage, accountEmail: String, accountToken: String, completion: ((_ error: ImageUploadError?) -> Void)?) {
        Task {
            do {
                try await uploadImage(image, accountEmail: accountEmail, accountToken: accountToken)
                completion?(nil)
            } catch let error as ImageUploadError {
                completion?(error)
            } catch {
                completion?(ImageUploadError.responseError(reason: .unexpected(error)))
            }
        }
    }

    private func cachedImageResult(for url: URL) -> GravatarImageDownloadResult? {
        guard let cachedImage = imageCache.getImage(forKey: url.absoluteString) else {
            return nil
        }
        return GravatarImageDownloadResult(image: cachedImage, sourceURL: url)
    }
}

private func imageUploadBody(with imageData: Data, account: String, boundary: String) -> Data {
    enum UploadParameters {
        static let contentType = "application/octet-stream"
        static let filename = "profile.png"
        static let imageKey = "filedata"
        static let accountKey = "account"
    }

    var body = Data()

    // Image Payload
    body.append("--\(boundary)\r\n")
    body.append("Content-Disposition: form-data; name=\(UploadParameters.imageKey); ")
    body.append("filename=\(UploadParameters.filename)\r\n")
    body.append("Content-Type: \(UploadParameters.contentType);\r\n\r\n")
    body.append(imageData)
    body.append("\r\n")

    // Account Payload
    body.append("--\(boundary)\r\n")
    body.append("Content-Disposition: form-data; name=\"\(UploadParameters.accountKey)\"\r\n\r\n")
    body.append("\(account)\r\n")

    // EOF!
    body.append("--\(boundary)--\r\n")

    return body as Data
}

extension Data {
    fileprivate mutating func append(_ string: String) {
        if let data = string.data(using: String.Encoding.utf8) {
            append(data)
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

    fileprivate static func imageUploadRequest(with boundary: String) -> URLRequest {
        let url = URL(string: "https://api.gravatar.com/v1/upload-image")!
        var request = URLRequest(url: url)
        request.addValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        return request
    }
}
