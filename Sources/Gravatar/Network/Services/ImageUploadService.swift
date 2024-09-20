import Foundation
import UIKit

/// A service to perform uploading images to Gravatar.
///
/// This is the default type which implements ``ImageUploader``..
/// Unless specified otherwise, `ImageUploadService` will use a `URLSession` based `HTTPClient`.
struct ImageUploadService: ImageUploader {
    private let client: HTTPClient

    init(client: HTTPClient? = nil) {
        self.client = client ?? URLSessionHTTPClient()
    }

    @discardableResult
    func uploadImage(_ image: UIImage, accessToken: String, additionalHTTPHeaders: [HTTPHeaderField]?) async throws -> (data: Data, response: HTTPURLResponse) {
        guard let data = image.jpegData(compressionQuality: 0.9) else {
            throw ImageUploadError.cannotConvertImageIntoData
        }

        return try await uploadImage(data: data, accessToken: accessToken, additionalHTTPHeaders: additionalHTTPHeaders)
    }

    private func uploadImage(data: Data, accessToken: String, additionalHTTPHeaders: [HTTPHeaderField]?) async throws -> (Data, HTTPURLResponse) {
        let boundary = "\(UUID().uuidString)"
        let request = URLRequest.imageUploadRequest(with: boundary, additionalHTTPHeaders: additionalHTTPHeaders)
            .settingDefaultAcceptLanguage()
            .settingAuthorizationHeaderField(with: accessToken)
        // For the Multipart form/data, we need to send the email address, not the id of the emai address
        let body = imageUploadBody(with: data, boundary: boundary)
        do {
            return try await client.uploadData(with: request, data: body)
        } catch let error as HTTPClientError {
            throw ImageUploadError.responseError(reason: error.map())
        } catch {
            throw ImageUploadError.responseError(reason: .unexpected(error))
        }
    }
}

private func imageUploadBody(with imageData: Data, boundary: String) -> Data {
    enum UploadParameters {
        static let contentType = "application/octet-stream"
        static let filename = "profile"
        static let imageKey = "image"
    }

    var body = Data()

    // Image Payload
    body.append("--\(boundary)\r\n")
    body.append("Content-Disposition: form-data; name=\(UploadParameters.imageKey); filename=\(UploadParameters.filename)\r\n")
    body.append("Content-Type: \(UploadParameters.contentType);\r\n\r\n")
    body.append(imageData)
    body.append("\r\n")
    body.append("\r\n")
    // EOF!
    body.append("--\(boundary)--\r\n")

    return body
}

extension Data {
    fileprivate mutating func append(_ string: String) {
        if let data = string.data(using: String.Encoding.utf8) {
            append(data)
        }
    }
}

extension URLRequest {
    fileprivate static func imageUploadRequest(with boundary: String, additionalHTTPHeaders: [HTTPHeaderField]?) -> URLRequest {
        let url = URL(string: "https://api.gravatar.com/v3/me/avatars")!
        var request = URLRequest(url: url)
        request.addValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        additionalHTTPHeaders?.forEach { headerTuple in
            request.addValue(headerTuple.value, forHTTPHeaderField: headerTuple.name)
        }
        return request
    }
}
