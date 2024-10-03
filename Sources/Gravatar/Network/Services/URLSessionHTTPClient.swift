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
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = [
            "Accept": "application/json",
        ]
        self.urlSession = urlSession ?? URLSession(configuration: configuration)
    }

    func fetchData(with request: URLRequest) async throws -> (Data, HTTPURLResponse) {
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
            if response.is4xxError {
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
