import Foundation

/// Common errors for all HTTP operations.
enum HTTPClientError: Error {
    case invalidHTTPStatusCodeError(HTTPURLResponse, Data)
    case invalidURLResponseError(URLResponse)
    case URLSessionError(Error)
}

private enum Constants {
    static let sdkName = "Gravatar-SDK-iOS"
}

struct URLSessionHTTPClient: HTTPClient {
    private let urlSession: URLSessionProtocol

    init(urlSession: URLSessionProtocol? = nil) {
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = [
            "Accept": "application/json",
            "User-Agent": Self.userAgent(),
        ]
        self.urlSession = urlSession ?? URLSession(configuration: configuration)
    }

    func data(with request: URLRequest) async throws -> (Data, HTTPURLResponse) {
        let result: (data: Data, response: URLResponse)
        do {
            result = try await urlSession.data(for: request)
        } catch {
            throw HTTPClientError.URLSessionError(error)
        }
        let httpResponse = try validatedHTTPResponse(result.response, data: result.data)
        return (result.data, httpResponse)
    }

    func uploadData(with request: URLRequest, data: Data) async throws -> (Data, HTTPURLResponse) {
        let result: (data: Data, response: URLResponse)
        do {
            result = try await urlSession.upload(for: request, from: data)
        } catch {
            throw HTTPClientError.URLSessionError(error)
        }
        return try (result.data, validatedHTTPResponse(result.response, data: result.data))
    }
}

extension URLRequest {
    func settingAuthorizationHeaderField(with token: String) -> URLRequest {
        var requestCopy = self
        requestCopy.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return requestCopy
    }
}

extension URLSessionHTTPClient {
    private static func userAgent() -> String {
        "\(sdkUserAgentString()) \(osUserAgentString())  \(appUserAgentString())"
    }

    private static func osName() -> String {
        let osName: String
        #if os(iOS)
        osName = "iOS"
        #else
        osName = "Unknown OS"
        assertionFailure("Update '\(#function)' to include the current OS name (iOS, macOS, tvOS, watchOS) when adding support for it.")
        #endif
        return osName
    }

    private static func appUserAgentString() -> String {
        userAgentProduct(
            product: BundleInfo.appName,
            version: BundleInfo.appVersion
        )
    }

    private static func osUserAgentString() -> String {
        userAgentProduct(
            product: osName(),
            version: ProcessInfo.processInfo.osVersionDottedString
        )
    }

    private static func sdkUserAgentString() -> String {
        userAgentProduct(
            product: Constants.sdkName,
            version: BundleInfo.sdkVersion
        )
    }

    private static func userAgentProduct(product: String?, version: String?) -> String {
        var encodedProduct = product?.addingPercentEncoding(withAllowedCharacters: .productIdentifierAllowed) ?? "Unknown"

        if let encodedVersion = version?.addingPercentEncoding(withAllowedCharacters: .productIdentifierAllowed) {
            encodedProduct += "/\(encodedVersion)"
        }
        return encodedProduct
    }
}

private func validatedHTTPResponse(_ response: URLResponse, data: Data) throws -> HTTPURLResponse {
    guard let httpResponse = response as? HTTPURLResponse else {
        throw HTTPClientError.invalidURLResponseError(response)
    }
    if httpResponse.isError {
        throw HTTPClientError.invalidHTTPStatusCodeError(httpResponse, data)
    }
    return httpResponse
}

extension HTTPClientError {
    func map() -> ResponseErrorReason {
        switch self {
        case .URLSessionError(let error):
            return .URLSessionError(error: error)
        case .invalidHTTPStatusCodeError(let response, let data):
            if response.isClientError {
                let error: ModelError? = try? data.decode()
                return .invalidHTTPStatusCode(response: response, errorPayload: error)
            } else {
                return .invalidHTTPStatusCode(response: response)
            }
        case .invalidURLResponseError(let response):
            return .invalidURLResponse(response: response)
        }
    }
}
