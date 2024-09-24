import Foundation

struct AccessToken {
    let accessToken: String
    let expiresIn: Int?
    let tokenType: String?
}

extension AccessToken {
    /// Initialize an AccessToken from a URL Callback
    /// - Parameter callbackURL: the OAuth2 callback URL
    init?(from callbackURL: URL) {
        // Extract the fragment part of the URL
        guard let fragment = callbackURL.fragment else { return nil }

        // Convert the fragment into a valid query string by replacing `#` with `?`
        let fragmentAsQuery = "?" + fragment

        // Use URLComponents to parse the fragment as query parameters
        guard let components = URLComponents(string: fragmentAsQuery),
              let queryItems = components.queryItems else { return nil }

        // Create a dictionary of query parameters
        let parameters = queryItems.reduce(into: [String: String]()) { result, item in
            result[item.name] = item.value
        }

        // Extract required access_token
        guard let accessToken = parameters["access_token"] else { return nil }

        // Extract optional expires_in and token_type
        let expiresIn = parameters["expires_in"].flatMap { Int($0) }
        let tokenType = parameters["token_type"]

        // Initialize the AccessToken with extracted values
        self.accessToken = accessToken
        self.expiresIn = expiresIn
        self.tokenType = tokenType
    }
}
