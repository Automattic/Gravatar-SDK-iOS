import Foundation
import UIKit

/// A service to perform uploading images to Gravatar.
///
/// This is the default type which implements ``ImageUploader``.
struct ImageUploadService: ImageUploader {
    private let client: HTTPClient

    init(urlSession: URLSessionProtocol? = nil) {
        self.client = URLSessionHTTPClient(urlSession: urlSession)
    }

    @discardableResult
    func uploadImage(
        _ image: UIImage,
        accessToken: String,
        avatarSelection: AvatarSelection = .preserveSelection,
        additionalHTTPHeaders: [HTTPHeaderField]?
    ) async throws -> (data: Data, response: HTTPURLResponse) {
        guard let data: Data = {
            if #available(iOS 17.0, *) {
                image.heicData()
            } else {
                image.jpegData(compressionQuality: 0.8)
            }
        }() else {
            throw ImageUploadError.cannotConvertImageIntoData
        }

        return try await uploadImage(data: data, accessToken: accessToken, avatarSelection: avatarSelection, additionalHTTPHeaders: additionalHTTPHeaders)
    }

    private func uploadImage(
        data: Data,
        accessToken: String,
        avatarSelection: AvatarSelection,
        additionalHTTPHeaders: [HTTPHeaderField]?
    ) async throws -> (Data, HTTPURLResponse) {
        let boundary = "\(UUID().uuidString)"
        let request = URLRequest.imageUploadRequest(
            with: boundary,
            additionalHTTPHeaders: additionalHTTPHeaders,
            selectionBehavior: avatarSelection
        ).settingAuthorizationHeaderField(with: accessToken)

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
    imageUploadBodyV3(with: imageData, boundary: boundary)
}

private func imageUploadBodyV3(with imageData: Data, boundary: String) -> Data {
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
    fileprivate static func imageUploadRequest(
        with boundary: String,
        additionalHTTPHeaders: [HTTPHeaderField]?,
        selectionBehavior: AvatarSelection
    ) -> URLRequest {
        var request = URLRequest(url: .imageUploadURL.appendingQueryItems(for: selectionBehavior))
        request.addValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        additionalHTTPHeaders?.forEach { headerTuple in
            request.addValue(headerTuple.value, forHTTPHeaderField: headerTuple.name)
        }
        return request
    }
}

extension URL {
    fileprivate static var imageUploadURL: URL {
        APIConfig.baseURL.appendingPathComponent("v3/me/avatars")
    }
}

extension URL {
    func appendingQueryItems(for selectionBehavior: AvatarSelection) -> URL {
        let queryItems = selectionBehavior.queryItems
        if #available(iOS 16.0, *) {
            return self.appending(queryItems: queryItems)
        } else {
            var components = URLComponents(string: absoluteString)
            components?.queryItems = queryItems
            return components?.url ?? self
        }
    }
}

extension AvatarSelection {
    var queryItems: [URLQueryItem] {
        switch self {
        case .selectUploadedImage(let email):
            [
                .init(name: "select_avatar", value: "true"),
                .init(name: "selected_email_hash", value: email.id),
            ]
        case .preserveSelection:
            [.init(name: "select_avatar", value: "false")]
        case .selectUploadedImageIfNoneSelected(let email):
            [.init(name: "selected_email_hash", value: email.id)]
        }
    }
}
