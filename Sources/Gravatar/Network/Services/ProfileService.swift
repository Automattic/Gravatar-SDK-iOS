import Foundation

private let baseURL = URL(string: "https://api.gravatar.com/v3/profiles/")!
private let avatarsBaseURLComponents = URLComponents(string: "https://api.gravatar.com/v3/me/avatars")!

private func selectAvatarBaseURL(with avatarID: String) -> URL? {
    URL(string: "https://api.gravatar.com/v3/me/avatars/\(avatarID)/email")
}

/// A service to perform Profile related tasks.
///
/// By default, the ``Profile`` instance returned by ``fetch(with:)`` will contain only a subset of the abailable information.
///
/// To obtain the full profile information, you need to configure an API Key using ``Configuration``
public struct ProfileService: ProfileFetching, Sendable {
    private let client: HTTPClient

    /// Creates a new `ProfileService`.
    /// - Parameters:
    ///   - urlSession: Manages the network tasks. It can be a [URLSession] or any other type that conforms to ``URLSessionProtocol``.
    /// If not provided, a properly configured [URLSession] is used.
    ///
    /// [URLSession]: https://developer.apple.com/documentation/foundation/urlsession
    public init(urlSession: URLSessionProtocol? = nil) {
        self.client = URLSessionHTTPClient(urlSession: urlSession)
    }

    public func fetch(with profileID: ProfileIdentifier) async throws -> Profile {
        let url = baseURL.appending(pathComponent: profileID.id)
        let request = await URLRequest(url: url).authorized()
        return try await fetch(with: request)
    }

    package func fetchAvatars(with token: String, id: ProfileIdentifier) async throws -> [Avatar] {
        do {
            guard let url = avatarsBaseURLComponents.settingQueryItems([.init(name: "selected_email_hash", value: id.id)]).url else {
                throw APIError.requestError(reason: .urlInitializationFailed)
            }
            let request = URLRequest(url: url).settingAuthorizationHeaderField(with: token)
            let (data, _) = try await client.fetchData(with: request)
            return try data.decode()
        } catch {
            throw error.apiError()
        }
    }

    package func selectAvatar(token: String, profileID: ProfileIdentifier, avatarID: String) async throws -> Avatar {
        guard let url = selectAvatarBaseURL(with: avatarID) else {
            throw APIError.requestError(reason: .urlInitializationFailed)
        }

        do {
            var request = URLRequest(url: url).settingAuthorizationHeaderField(with: token)
            request.httpMethod = "POST"
            request.httpBody = try SelectAvatarBody(emailHash: profileID.id).data
            let (data, _) = try await client.fetchData(with: request)
            return try data.decode()
        } catch {
            throw error.apiError()
        }
    }
}

extension ProfileService {
    private func fetch(with request: URLRequest) async throws -> Profile {
        do {
            let (data, _) = try await client.fetchData(with: request)
            let profileResult: Profile = try data.decode()
            return profileResult
        } catch {
            throw error.apiError()
        }
    }
}

extension URLRequest {
    private enum HeaderField: String {
        case authorization = "Authorization"
    }

    fileprivate func authorized() async -> URLRequest {
        guard let key = await Configuration.shared.apiKey else { return self }
        let bearerKey = "Bearer \(key)"
        var copy = self
        copy.setValue(bearerKey, forHTTPHeaderField: HeaderField.authorization.rawValue)
        return copy
    }
}

private struct SelectAvatarBody: Encodable, Sendable {
    private let emailHash: String

    init(emailHash: String) {
        self.emailHash = emailHash
    }

    var data: Data {
        get throws {
            let encoder = JSONEncoder()
            encoder.keyEncodingStrategy = .convertToSnakeCase
            return try encoder.encode(self)
        }
    }
}
