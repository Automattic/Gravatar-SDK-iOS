import Foundation

/// Common errors for all HTTP operations.
enum HTTPClientError: Error {
    case invalidHTTPStatusCodeError(HTTPURLResponse, Data)
    case invalidURLResponseError(URLResponse)
    case URLSessionError(Error)
}

struct URLSessionHTTPClient: HTTPClient {
    private let urlSession: URLSessionProtocol

    init(urlSession: URLSessionProtocol? = nil) {
        self.urlSession = urlSession ?? URLSession(configuration: URLSessionConfiguration.default)
    }

    func data(with request: URLRequest) async throws -> (Data, HTTPURLResponse) {
        let request = request.withHeaders()
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
        let request = request.withHeaders()
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

    func withHeaders() -> URLRequest {
        var request = self
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("ios", forHTTPHeaderField: "X-Platform")
        request.addValue(BundleInfo.sdkVersion ?? "", forHTTPHeaderField: "X-SDK-Version")
        request.addValue(BundleInfo.appName ?? "", forHTTPHeaderField: "X-Source")
        return request
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
