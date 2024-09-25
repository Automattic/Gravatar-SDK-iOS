import Foundation

package struct CheckTokenAuthorizationService: Sendable {
    
    private let client: HTTPClient

    package init(session: URLSession? = nil) {
        if let session {
            self.client = URLSessionHTTPClient(urlSession: session)
        }
        else {
            self.client = URLSessionHTTPClient()
        }
    }

    /// Checks if the given access token is authorized to make changes to this Gravatar account.
    /// - Parameters:
    ///   - token: WordPress.com access token.
    ///   - email: Email to check.
    package func isToken(_ token: String, authorizedFor email: Email) async throws -> Bool  {
        var urlComponents = ServiceConfig.v3BaseURLComponents
        urlComponents.path = "/me/associated-email"
        urlComponents.queryItems = [
            URLQueryItem(name: "email_hash", value: email.hashID.id),
        ]
        guard let url = urlComponents.url else {
            throw APIError.requestError(reason: .urlInitializationFailed)
        }
        var request = URLRequest(url: url).settingAuthorizationHeaderField(with: token)
        request.httpMethod = "GET"
        do {
            let (data, _) = try await client.fetchData(with: request)
            let result: AssociatedEmail200Response = try data.decode()
            return result.associated
        } catch {
            throw error.apiError()
        }
    }
}
