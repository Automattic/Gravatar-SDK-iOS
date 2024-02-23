import UIKit

public struct ImageService {
    private let client: HTTPClient
    let imageCache: GravatarImageCaching

    public init(client: HTTPClient? = nil, cache: GravatarImageCaching? = nil) {
        self.client = client ?? URLSessionHTTPClient()
        self.imageCache = cache ?? GravatarImageCache()
    }

    func fetchImage(from url: URL, procressor: ImageProcessor) async throws -> (image: UIImage, url: URL) {
        let request = URLRequest.imageRequest(url: url)
        let (data, response) = try await client.fetchData(with: request)

        guard let responseUrl = response.url else {
            throw GravatarImageDownloadError.responseError(reason: .urlMissingInResponse)
        }

        guard let image = procressor.process(data) else {
            throw GravatarImageDownloadError.responseError(reason: .imageInitializationFailed)
        }

        guard url == response.url else {
            throw GravatarImageDownloadError.responseError(reason: .urlMismatch)
        }

        imageCache.setImage(image, forKey: url.absoluteString)
        return (image, responseUrl)
    }

    func uploadImage(data: Data, accountEmail: String, accountToken: String) async throws -> URLResponse {
        let boundary = "Boundary-\(UUID().uuidString)"
        let request = URLRequest.imageUploadRequest(with: boundary).settingAuthorizationHeaderField(with: accountToken)
        let body = imageUploadBody(with: data, account: accountEmail, boundary: boundary)
        let response = try await client.uploadData(with: request, data: body)
        return response
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
    fileprivate static func imageRequest(url: URL) -> URLRequest {
        var request = URLRequest(url: url)
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
