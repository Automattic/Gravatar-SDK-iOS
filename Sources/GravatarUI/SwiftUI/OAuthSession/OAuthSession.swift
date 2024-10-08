import AuthenticationServices

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

    public init() {
        self.authenticationSession = OldAuthenticationSession()
        self.storage = Keychain()
    }

    public func hasSession(with email: Email) -> Bool {
        (try? storage.secret(with: email.rawValue) ?? nil) != nil
    }

    func hasValidSession(with email: Email) -> Bool {
        guard let token = try? storage.secret(with: email.rawValue) else {
            return false
        }
        return !token.isExpired
    }

    func markSessionAsExpired(with email: Email) {
        guard var token = sessionToken(with: email), !token.isExpired else { return }
        token.isExpired = true
        overrideToken(token, for: email)
    }

    func overrideToken(_ token: KeychainToken, for email: Email) {
        deleteSession(with: email)
        try? storage.setSecret(token, for: email.rawValue)
    }

    public func deleteSession(with email: Email) {
        try? storage.deleteSecret(with: email.rawValue)
    }

    func sessionToken(with email: Email) -> KeychainToken? {
        try? storage.secret(with: email.rawValue)
    }

    @discardableResult
    func retrieveAccessToken(with email: Email) async throws -> KeychainToken {
        guard let secrets = await Configuration.shared.oauthSecrets else {
            assertionFailure("Trying to retrieve access token without configuring oauth secrets.")
            throw OAuthError.notConfigured
        }

        do {
            let url = try oauthURL(with: email, secrets: secrets)
            let callbackURL = try await authenticationSession.authenticate(using: url, callbackURLScheme: secrets.callbackScheme)
            let tokenText = try tokenResponse(from: callbackURL).token
            guard try await CheckTokenAuthorizationService().isToken(tokenText, authorizedFor: email) else {
                throw OAuthError.loggedInWithWrongEmail(email: email.rawValue)
            }
            let newToken = KeychainToken(token: tokenText)
            overrideToken(newToken, for: email)
            return newToken
        } catch {
            throw OAuthError.from(error: error)
        }
    }

    private func tokenResponse(from callbackURL: URL) throws -> AccessToken {
        guard let accessToken = AccessToken(from: callbackURL) else {
            throw OAuthError.couldNotParseAccessCode(callbackURL.absoluteString)
        }

        return accessToken
    }

    private func oauthURL(with email: Email, secrets: Configuration.OAuthSecrets) throws -> URL {
        let params = OAuthURLParams(email: email, secrets: secrets)
        var urlComponents = URLComponents(string: "https://public-api.wordpress.com/oauth2/authorize")!
        do {
            urlComponents = try urlComponents.settingQueryItems(params.queryItems, shouldEncodePlusChar: true)
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
}

enum OAuthError: Error {
    case notConfigured
    case couldNotCreateOAuthURLWithGivenSecrets
    case couldNotParseAccessCode(String)
    case oauthResponseError(String, ASWebAuthenticationSessionError.Code?)
    case unknown(Error)
    case couldNotStoreToken(Error)
    case decodingError(Error)
    case loggedInWithWrongEmail(email: String)
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
                return .oauthResponseError(error.localizedDescription, ASWebAuthenticationSessionError.Code(rawValue: error.code))
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
    var scope1: String
    var scope2: String
    var scope3: String

    public enum CodingKeys: String, CodingKey, CaseIterable {
        case clientID
        case responseType
        case blogID
        case redirectURI
        case userEmail
        case scope1 = "scope[1]"
        case scope2 = "scope[2]"
        case scope3 = "scope[3]"
    }

    init(email: Email, secrets: Configuration.OAuthSecrets) {
        self.clientID = secrets.clientID
        self.responseType = "token"
        self.blogID = "0"
        self.redirectURI = secrets.redirectURI
        self.userEmail = email.rawValue
        self.scope1 = "gravatar-profile:read"
        self.scope2 = "gravatar-profile:manage"
        self.scope3 = "auth"
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
                URLQueryItem(name: $0.key, value: $0.value)
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
