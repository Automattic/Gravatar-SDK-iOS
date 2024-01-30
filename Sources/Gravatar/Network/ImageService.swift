import UIKit

public struct ImageService {
    let remote: ServiceRemote

    public init(urlSession: URLSessionProtocol = URLSession.shared) {
        self.remote = ServiceRemote(urlSession: urlSession)
    }

    public func fetchImage(from email: String, imageProcressor: ImageProcessing = ImageProcessor()) async throws -> GravatarImageDownloadResult {
        let path = "avatar/\(try email.sha256())"

        let (data, response) = try await fetchImage(from: path)

        guard let url = response.url else {
            throw GravatarImageDownloadError.responseError(reason: .urlMismatch)
        }
        guard let image = imageProcressor.process(data: data) else {
            throw GravatarImageDownloadError.responseError(reason: .imageInitializationFailed)
        }

        return GravatarImageDownloadResult(image: image, sourceURL: url)
    }

    private func fetchImage(from path: String) async throws -> (Data, URLResponse) {
        let url = try remote.url(from: path)
        guard GravatarURL.isGravatarURL(url) else {
            throw GravatarServiceError.invalidURL
        }

        let request = URLRequest.imageRequest(url: url)

        return try await remote.fetchData(with: request)
    }

    @discardableResult
    public func uploadImage(_ image: UIImage, accountEmail: String, accountToken: String) async throws -> URLResponse {
        let boundary = "Boundary-\(UUID().uuidString)"
        var request = imageUploadRequest(with: boundary)
        remote.authenticateRequest(&request, token: accountToken)
        let body = imageUploadBody(with: image.pngData()!, account: accountEmail, boundary: boundary)
        let response = try await remote.uploadData(with: request, data: body)
        return response
    }

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

private func imageUploadRequest(with boundary: String) -> URLRequest {
    let url = URL(string: "https://api.gravatar.com/v1/upload-image")!
    var request = URLRequest(url: url)
    request.addValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
    request.httpMethod = "POST"
    return request
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
}
