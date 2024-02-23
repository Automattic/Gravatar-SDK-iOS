
import Foundation

private let baseUrl = "https://gravatar.com/"

/// Common errors for all HTTP operations.
enum HTTPClientError: Error {
    case invalidHTTPStatusCodeError(HTTPURLResponse)
    case invalidURLResponseError(URLResponse)
    case URLSessionError(Error)
}

/// Error thrown when URL can not be created with the given baseURL and path.
struct CannotCreateURLFromGivenPath: Error {
    let baseURL: String
    let path: String
}

struct URLSessionHTTPClient: HTTPClient {
    private let urlSession: URLSessionProtocol

    init(urlSession: URLSessionProtocol = URLSession(configuration: .default)) {
        self.urlSession = urlSession
    }

    func fetchData(with request: URLRequest) async throws -> (Data, URLResponse) {
        let result: (Data, URLResponse)
        do {
            result = try await urlSession.data(for: request)
        } catch {
            throw HTTPClientError.URLSessionError(error)
        }
        try validateResponse(result.1)
        return result
    }

    func uploadData(with request: URLRequest, data: Data) async throws -> URLResponse {
        let result: (Data, URLResponse)
        do {
            result = try await urlSession.upload(for: request, from: data)
        } catch {
            throw HTTPClientError.URLSessionError(error)
        }
        try validateResponse(result.1)
        return result.1
    }

    func fetchObject<T: Decodable>(from path: String) async throws -> T {
        let url = try url(from: path)
        let request = URLRequest(url: url)
        let (data, _) = try await fetchData(with: request)
        let object = try JSONDecoder().decode(T.self, from: data)
        return object
    }

    private func url(from path: String) throws -> URL {
        guard let url = URL(string: baseUrl + path) else {
            throw CannotCreateURLFromGivenPath(baseURL: baseUrl, path: path)
        }
        return url
    }
}

extension URLRequest {
    func settingAuthorizationHeaderField(with token: String) -> URLRequest {
        var requestCopy = self
        requestCopy.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return requestCopy
    }
}

private func validateResponse(_ response: URLResponse) throws {
    guard let httpResponse = response as? HTTPURLResponse else {
        throw HTTPClientError.invalidURLResponseError(response)
    }
    if isErrorResponse(httpResponse) {
        throw HTTPClientError.invalidHTTPStatusCodeError(httpResponse)
    }
}

private func isErrorResponse(_ response: HTTPURLResponse) -> Bool {
    response.statusCode >= 400 && response.statusCode < 600
}

extension HTTPClientError {
    func convertToResponseErrorReason() -> ResponseErrorReason {
        switch self {
        case .URLSessionError(let error):
            .URLSessionError(error: error)
        case .invalidHTTPStatusCodeError(let response):
            .invalidHTTPStatusCode(response: response)
        case .invalidURLResponseError(let response):
            .invalidURLResponse(response: response)
        }
    }
}
