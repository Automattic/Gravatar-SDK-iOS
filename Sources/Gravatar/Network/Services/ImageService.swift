import UIKit

/// A service to perform image-related tasks, such as fetching images by email and uploading images to Gravatar.
///
/// This is the default type which implements ``ImageDownloader`` and ``ImageUploader``.
/// Unless specified otherwise, `ImageService` will use a `URLSession` based `HTTPClient`, and a in-memory image cache.
public struct ImageService {
    private let client: HTTPClient
    let imageCache: ImageCaching

    /// Creates a new `ImageService`
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

    func fetchImage(from url: URL, forceRefresh: Bool, processor: ImageProcessor) async throws -> GravatarImageDownloadResult {
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

    func uploadImage(data: Data, accountEmail: String, accountToken: String) async throws -> URLResponse {
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
