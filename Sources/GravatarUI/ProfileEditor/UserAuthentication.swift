import AuthenticationServices

@ConfigActor
final class UserAuthenticator: Sendable {
    unowned let delegate: UserAuthenticatorDelegate
    let configuration: Configuration

    init(delegate: UserAuthenticatorDelegate, configuration: Configuration? = nil) {
        self.delegate = delegate
        self.configuration = configuration ?? .shared
    }

    @objc
    func showAuthScreen(on presentationContextProvider: WebAuthenticationPresentationContextProvider) async {
        guard
            let auth = Configuration.shared.auth,
            var authorizationURLComponents = URLComponents(string: "https://public-api.wordpress.com/oauth2/authorize"),
            let redirectURL = URL(string: auth.redirectURI)
        else { return }

        authorizationURLComponents.queryItems = [
            .init(name: "client_id", value: auth.clientID),
            .init(name: "redirect_uri", value: auth.redirectURI),
            .init(name: "response_type", value: "code"),
            .init(name: "scope", value: "auth"),
        ]

        guard let authorizationURL = authorizationURLComponents.url else { return }

        startAuthSession(
            authorizationURL: authorizationURL,
            scheme: redirectURL.scheme,
            presentationContextProvider: presentationContextProvider
        )
    }

    func startAuthSession(authorizationURL: URL, scheme: String?, presentationContextProvider: WebAuthenticationPresentationContextProvider) {
        let session = ASWebAuthenticationSession(url: authorizationURL, callbackURLScheme: scheme) { callbackURL, error in
            print("error: \(String(describing: error))")

            guard let callbackURL else { return }

            let code = URLComponents(url: callbackURL, resolvingAgainstBaseURL: false)?
                .queryItems?
                .first { $0.name == "code" }
                .map { $0.value } ?? nil

            guard let code else { return }

            Task {
                await self.requestAccessToken(code: code)
            }
        }
        session.presentationContextProvider = presentationContextProvider
        session.start()
    }

    func requestAccessToken(code: String) async {
        guard let tokenURL = URL(string: "https://public-api.wordpress.com/oauth2/token") else { return }
        let params = Params(code: code)

        var request = URLRequest(url: tokenURL)
        request.httpMethod = "POST"
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        do {
            request.httpBody = try params.queryItems.string?.data(using: .utf8)
            let (data, response) = try await URLSession.shared.data(for: request)
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            if let httpResponse = (response as? HTTPURLResponse), httpResponse.statusCode >= 400 {
                let error = try decoder.decode(AuthError.self, from: data)
                // TODO: Error handling
                print(error)
            } else {
                let auth = try decoder.decode(AuthResponse.self, from: data)
                delegate.userAuthenticator(self, finishedAuthenticationSuccessfulyWithToken: auth.accessToken)
            }
        } catch {
            // TODO: Error handling
            print(String(describing: error))
        }
    }
}

protocol UserAuthenticatorDelegate: AnyObject, Sendable {
    func userAuthenticator(_ authenticator: UserAuthenticator, finishedAuthenticationSuccessfulyWithToken token: String)
}

final class WebAuthenticationPresentationContextProvider: NSObject, ASWebAuthenticationPresentationContextProviding, Sendable {
    let window: UIWindow
    init(window: UIWindow) {
        self.window = window
    }
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        window
    }
}

@ConfigActor
private struct Params: Encodable {
    let client_id: String = Configuration.shared.auth?.clientID ?? ""
    let redirect_uri: String = Configuration.shared.auth?.redirectURI ?? ""
    let client_secret: String = Configuration.shared.auth?.clientSecret ?? ""
    let grant_type: String = "authorization_code"
    let code: String

    init(code: String) {
        self.code = code
    }
}

extension Encodable {
    fileprivate var queryItems: [URLQueryItem] {
        get throws {
            let data = try JSONEncoder().encode(self)
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

private struct AuthResponse: Decodable {
    let accessToken: String
}

private struct AuthError: Decodable {
    let error: String
    let errorDescription: String
}
