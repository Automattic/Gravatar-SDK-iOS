import UIKit

private let baseUrl = "https://gravatar.com/"

struct ServiceRemote {
    let urlSession: URLSessionProtocol

    init(urlSession: URLSessionProtocol = URLSession(configuration: .default)) {
        self.urlSession = urlSession
    }

    func fetchData(with request: URLRequest) async throws -> (Data, URLResponse) {
        let (data, urlResponse) = try await urlSession.data(for: request)
        if let response = urlResponse as? HTTPURLResponse, isErrorResponse(response) {
            throw error(for: response)
        }
        return (data, urlResponse)
    }

    func fetchObject<T: Decodable>(from path: String) async throws -> T {
        let url = try url(from: path)
        let request = URLRequest(url: url)
        let (data, _) = try await fetchData(with: request)
        let object = try JSONDecoder().decode(T.self, from: data)
        return object
    }

    func fetchImage(from path: String, imageProcressor: ImageProcessing = ImageProcessor()) async throws -> GravatarImageDownloadResult {
        let url = try url(from: path)
        let request = URLRequest.imageRequest(url: url)

        let (data, response) = try await fetchData(with: request)
        guard let url = response.url else {
            throw GravatarImageDownloadError.responseError(reason: .urlMismatch)
        }
        guard let image = imageProcressor.process(data: data) else {
            throw GravatarImageDownloadError.responseError(reason: .imageInitializationFailed)
        }

        return GravatarImageDownloadResult(image: image, sourceURL: url)
    }
}

private func url(from path: String) throws -> URL {
    guard let url = URL(string: baseUrl + path) else {
        throw GravatarServiceError.invalidURL
    }
    return url
}

private func isErrorResponse(_ response: HTTPURLResponse) -> Bool {
    response.statusCode >= 400 && response.statusCode < 600
}

private func error(for response: HTTPURLResponse) -> NSError {
    NSError(
        domain: NSURLErrorDomain,
        code: response.statusCode,
        userInfo: [NSLocalizedDescriptionKey: HTTPURLResponse.localizedString(forStatusCode: response.statusCode)]
    )
}

private extension URLRequest {
    static func imageRequest(url: URL) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpShouldHandleCookies = false
        request.addValue("image/*", forHTTPHeaderField: "Accept")
        return request
    }
}
