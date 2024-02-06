
import Foundation

private let baseUrl = "https://gravatar.com/"

public enum HTTPClientError: Error {
    case cannotCreateURLFromGivenPath
}

struct URLSessionHTTPClient: HTTPClient {
    private let urlSession: URLSessionProtocol

    init(urlSession: URLSessionProtocol = URLSession(configuration: .default)) {
        self.urlSession = urlSession
    }

    func fetchData(with request: URLRequest) async throws -> (Data, URLResponse) {
        let (data, urlResponse) = try await urlSession.data(for: request)
        if let response = urlResponse as? HTTPURLResponse, isErrorResponse(response) {
            throw error(from: response)
        }
        return (data, urlResponse)
    }

    func uploadData(with request: URLRequest, data: Data) async throws -> URLResponse {
        let (_, urlResponse) = try await urlSession.upload(for: request, from: data)
        if let response = urlResponse as? HTTPURLResponse, isErrorResponse(response) {
            throw error(from: response)
        }
        return urlResponse
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
            throw HTTPClientError.cannotCreateURLFromGivenPath
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

private func isErrorResponse(_ response: HTTPURLResponse) -> Bool {
    response.statusCode >= 400 && response.statusCode < 600
}

private func error(from response: HTTPURLResponse) -> NSError {
    NSError(
        domain: NSURLErrorDomain,
        code: response.statusCode,
        userInfo: [NSLocalizedDescriptionKey: HTTPURLResponse.localizedString(forStatusCode: response.statusCode)]
    )
}
