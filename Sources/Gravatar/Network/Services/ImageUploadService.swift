import Foundation
import UIKit

/// A service to perform uploading images to Gravatar.
///
/// This is the default type which implements ``ImageUploader``..
/// Unless specified otherwise, `ImageUploadService` will use a `URLSession` based `HTTPClient`.
package struct ImageUploadService: ImageUploader {
    private let client: HTTPClient

    package init(client: HTTPClient? = nil) {
        self.client = client ?? URLSessionHTTPClient()
    }

    @discardableResult
    package func uploadImage(_ image: UIImage, email: Email, accessToken: String, additionalHTTPHeaders: [HTTPHeaderField]?) async throws -> URLResponse {
        guard let data = image.pngData() else {
            throw ImageUploadError.cannotConvertImageIntoData
        }

        return try await uploadImage(data: data, email: email, accessToken: accessToken, additionalHTTPHeaders: additionalHTTPHeaders)
    }

    private func uploadImage(data: Data, email: Email, accessToken: String, additionalHTTPHeaders: [HTTPHeaderField]?) async throws -> URLResponse {
        let boundary = "Boundary-\(UUID().uuidString)"
        let request = URLRequest.imageUploadRequest(with: boundary, additionalHTTPHeaders: additionalHTTPHeaders)
            .settingAuthorizationHeaderField(with: accessToken)
        // For the Multipart form/data, we need to send the email address, not the id of the emai address
        let body = imageUploadBody(with: data, account: email.rawValue, boundary: boundary) // TODO:
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
    fileprivate static func imageUploadRequest(with boundary: String, additionalHTTPHeaders: [HTTPHeaderField]?) -> URLRequest {
        let url = URL(string: "https://api.gravatar.com/v1/upload-image")!
        var request = URLRequest(url: url)
        request.addValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        additionalHTTPHeaders?.forEach { headerTuple in
            request.addValue(headerTuple.value, forHTTPHeaderField: headerTuple.name)
        }
        return request
    }
}
