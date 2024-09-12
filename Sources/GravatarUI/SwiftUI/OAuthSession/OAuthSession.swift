import AuthenticationServices
import Gravatar

public struct OAuthSession: Sendable {
    private let storage: SecureStorage
    private let authenticationSession: AuthenticationSession
    private let snakeCaseDecoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }()

    init(authenticationSession: AuthenticationSession = OldAuthenticationSession(), storage: SecureStorage = Keychain()) {
        self.authenticationSession = authenticationSession
        self.storage = storage
    }

    public func hasSession(with email: Email) -> Bool {
        (try? storage.secret(with: email.rawValue) ?? nil) != nil
    }

    public func deleteSession(with email: Email) {
        try? storage.deleteSecret(with: email.rawValue)
    }

    func sessionToken(with email: Email) -> String? {
        try? storage.secret(with: email.rawValue)
    }

    @discardableResult
    func retrieveAccessToken(with email: Email) async throws -> String {
        guard let secrets = await Configuration.shared.oauthSecrets else {
            assertionFailure("Trying to retrieve access token without configuring oauth secrets.")
            throw OAuthError.notConfigured
        }

        do {
            let url = try oauthURL(with: email, secrets: secrets)
            let callbackURL = try await authenticationSession.authenticate(using: url, callbackURLScheme: secrets.callbackScheme)
            let token = try await getToken(from: callbackURL, secrets: secrets)
            try storage.setSecret(token, for: email.rawValue)
            return token
        } catch {
            throw OAuthError.from(error: error)
        }
    }

    private func getToken(from callbackURL: URL, secrets: Configuration.OAuthSecrets) async throws -> String {
        let queryItems = URLComponents(string: callbackURL.absoluteString)?.queryItems
        guard let code = queryItems?.filter({ $0.name == "code" }).first?.value else {
            throw OAuthError.couldNotParseAccessCode(callbackURL.absoluteString)
        }

        return try await requestAccessToken(code: code, secrets: secrets)
    }

    private func requestAccessToken(code: String, secrets: Configuration.OAuthSecrets) async throws -> String {
        do {
            let request = try accessTokenRequest(with: code, secrets: secrets)
            let (data, response) = try await URLSession.shared.data(for: request)

            if let httpResponse = (response as? HTTPURLResponse), httpResponse.statusCode >= 400 {
                let error = try snakeCaseDecoder.decode(RemoteOAuthError.self, from: data)
                throw OAuthError.oauthResponseError(error.errorDescription)
            } else {
                let auth = try snakeCaseDecoder.decode(OAuthResponse.self, from: data)
                return auth.accessToken
            }
        } catch {
            throw error
        }
    }

    private func oauthURL(with email: Email, secrets: Configuration.OAuthSecrets) throws -> URL {
        do {
            let queryItems = try OAuthURLParams(email: email, secrets: secrets).queryItems
            let urlComponents = URLComponents(
                string: "https://public-api.wordpress.com/oauth2/authorize",
                queryItems: queryItems
            )!
            guard let finalURL = urlComponents.url else {
                assertionFailure(
                    "Error encoding oauth secrets. Check the config in `Configuration.shared.configure(with:oauthSecrets:)` and try again"
                )
                throw OAuthError.couldNotCreateOAuthURLWithGivenSecrets
            }
            return finalURL
        } catch {
            assertionFailure(
                "Error encoding oauth secrets. Check the config in `Configuration.shared.configure(with:oauthSecrets:)` and try again"
            )
            throw OAuthError.couldNotCreateOAuthURLWithGivenSecrets
        }
    }

    private func accessTokenRequest(with code: String, secrets: Configuration.OAuthSecrets) throws -> URLRequest {
        let tokenURL = URL(string: "https://public-api.wordpress.com/oauth2/token")!
        let params = AccessTokenRequestParams(secrets: secrets, code: code)

        var request = URLRequest(url: tokenURL)
        request.httpMethod = "POST"
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpBody = try params.queryItems.string?.data(using: .utf8)

        return request
    }
}

enum OAuthError: Error {
    case notConfigured
    case couldNotCreateOAuthURLWithGivenSecrets
    case couldNotParseAccessCode(String)
    case oauthResponseError(String)
    case unknown(Error)
    case couldNotStoreToken(Error)
    case decodingError(Error)
}

extension OAuthError {
    static func from(error: Error) -> OAuthError {
        switch error {
        case let error as OAuthError:
            return error
        case let error as Keychain.KeychainError:
            return .couldNotStoreToken(error)
        case let error as DecodingError:
            assertionFailure("Unable to decode the response. Error: \(error.localizedDescription)")
            return OAuthError.decodingError(error)
        case let error as NSError:
            if error.domain == ASWebAuthenticationSessionErrorDomain {
                return .oauthResponseError(error.localizedDescription)
            }
            return .unknown(error)
        default:
            return .unknown(error)
        }
    }
}

private struct AccessTokenRequestParams: Encodable {
    let clientID: String
    let redirectURI: String
    let clientSecret: String
    let grantType: String = "authorization_code"
    let code: String

    init(secrets: Configuration.OAuthSecrets, code: String) {
        clientID = secrets.clientID
        redirectURI = secrets.redirectURI
        clientSecret = secrets.clientSecret
        self.code = code
    }
}

private struct OAuthURLParams: Encodable {
    let clientID: String
    let responseType: String
    let blogID: String
    let redirectURI: String
    let userEmail: String

    init(email: Email, secrets: Configuration.OAuthSecrets) {
        self.clientID = secrets.clientID
        self.responseType = "code"
        self.blogID = "0"
        self.redirectURI = secrets.redirectURI
        self.userEmail = email.rawValue
    }
}

private struct OAuthResponse: Decodable {
    let accessToken: String
}

private struct RemoteOAuthError: Decodable {
    let error: String
    let errorDescription: String
}

extension Encodable {
    fileprivate var queryItems: [URLQueryItem] {
        get throws {
            let encoder = JSONEncoder()
            encoder.keyEncodingStrategy = .convertToSnakeCase
            let data = try encoder.encode(self)
            let dictionary = try JSONSerialization.jsonObject(with: data) as? [String: String]
            return dictionary?.map {
                print("key: \($0.key) | value: \($0.value)")
                let queryItem = URLQueryItem(name: $0.key, value: $0.value)
                print("URLQueryItem: \(queryItem)")
                return queryItem
            } ?? []
        }
    }
}

extension [URLQueryItem] {
    fileprivate var string: String? {
        var components = URLComponents()
        components.queryItems = self
        return components.query
    }
}

protocol AuthenticationSession: Sendable {
    func authenticate(using url: URL, callbackURLScheme: String) async throws -> URL
}

extension OldAuthenticationSession: AuthenticationSession {}
