import UIKit

public struct ImageService {
    private let client: HTTPClient
    private let imageCache: GravatarImageCaching

    public init(client: HTTPClient? = nil, cache: GravatarImageCaching = GravatarImageCache()) {
        self.client = client ?? URLSessionHTTPClient()
        self.imageCache = cache
    }

    public func retrieveImage(
        with email: String,
        options: GravatarImageDownloadOptions = GravatarImageDownloadOptions(),
        completionHandler: ImageDownloadCompletion? = nil
    ) {
        Task {
            do {
                let result = try await fetchImage(with: email, options: options)
                completionHandler?(Result.success(result))
            } catch let error as GravatarImageDownloadError {
                completionHandler?(Result.failure(error))
            } catch {
                completionHandler?(Result.failure(GravatarImageDownloadError.responseError(reason: .URLSessionError(error: error))))
            }
        }
    }

    public func fetchImage(
        with email: String,
        options: GravatarImageDownloadOptions = GravatarImageDownloadOptions()
    ) async throws -> GravatarImageDownloadResult {

        let size = options.preferredSize ?? GravatarImageDownloadOptions.defaultSize
        let targetSize = max(size.width, size.height) * options.scaleFactor

        guard let gravatarURL = GravatarURL.gravatarUrl(for: email, size: Int(targetSize), rating: options.gravatarRating) else {
            throw GravatarImageDownloadError.requestError(reason: .urlInitializationFailed)
        }

        if !options.forceRefresh, let cachedImage = imageCache.getImage(forKey: gravatarURL.absoluteString) {
            return GravatarImageDownloadResult(image: cachedImage, sourceURL: gravatarURL)
        }

        return try await fetchImage(from: gravatarURL, imageProcressor: options.processor)
    }

    private func fetchImage(from url: URL, imageProcressor: GravatarImageProcessor) async throws -> GravatarImageDownloadResult {
        let request = URLRequest.imageRequest(url: url)
        let (data, response) = try await client.fetchData(with: request)

        guard let responseUrl = response.url else {
            throw GravatarImageDownloadError.responseError(reason: .urlMissingInResponse)
        }

        guard let image = imageProcressor.process(data) else {
            throw GravatarImageDownloadError.responseError(reason: .imageInitializationFailed)
        }

        imageCache.setImage(image, forKey: url.absoluteString)
        return GravatarImageDownloadResult(image: image, sourceURL: responseUrl)
    }

    @discardableResult
    public func uploadImage(_ image: UIImage, accountEmail: String, accountToken: String) async throws -> URLResponse {
        guard let data = image.pngData() else {
            throw UploadError.cannotConvertImageIntoData
        }

        let boundary = "Boundary-\(UUID().uuidString)"
        let request = URLRequest.imageUploadRequest(with: boundary).settingAuthorizationHeaderField(with: accountToken)
        let body = imageUploadBody(with: data, account: accountEmail, boundary: boundary)
        let response = try await client.uploadData(with: request, data: body)
        return response
    }

    // TODO: Return internal SDK error (or remove completion handler support)
    public func uploadImage(_ image: UIImage, accountEmail: String, accountToken: String, completion: ((_ error: NSError?) -> Void)?) {
        Task {
            do {
                try await uploadImage(image, accountEmail: accountEmail, accountToken: accountToken)
                completion?(nil)
            } catch {
                completion?(error as NSError)
            }
        }
    }
}

private func imageUploadBody(with imageData: Data, account: String, boundary: String) -> Data {
    enum UploadParameters {
        static let contentType          = "application/octet-stream"
        static let filename             = "profile.png"
        static let imageKey             = "filedata"
        static let accountKey           = "account"
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

private extension Data {
    mutating func append(_ string: String) {
        if let data = string.data(using: String.Encoding.utf8) {
            append(data)
        }
    }
}

private extension URLRequest {
    static func imageRequest(url: URL) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpShouldHandleCookies = false
        request.addValue("image/*", forHTTPHeaderField: "Accept")
        return request
    }

    static func imageUploadRequest(with boundary: String) -> URLRequest {
        let url = URL(string: "https://api.gravatar.com/v1/upload-image")!
        var request = URLRequest(url: url)
        request.addValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        return request
    }
}
