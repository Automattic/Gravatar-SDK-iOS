import Foundation

private let baseURL = URL(string: "https://api.gravatar.com/v3/profiles/")!
private let avatarsBaseURL = URL(string: "https://api.gravatar.com/v3/me/avatars")!
private let identitiesBaseURL = "https://api.gravatar.com/v3/me/identities/"

private func selectAvatarBaseURL(with profileID: ProfileIdentifier) -> URL? {
    URL(string: "https://api.gravatar.com/v3/me/identities/\(profileID.id)/avatar")
}

/// A service to perform Profile related tasks.
///
/// By default, the ``Profile`` instance returned by ``fetch(with:)`` will contain only a subset of the abailable information.
///
/// To obtain the full profile information, you need to configure an API Key using ``Configuration``
public struct ProfileService: ProfileFetching, Sendable {
    private let client: HTTPClient

    /// Creates a new `ProfileService`.
    ///
    /// Optionally, you can pass a custom type conforming to ``HTTPClient`` to gain control over networking tasks.
    /// - Parameter client: A type which will perform basic networking operations.
    public init(client: HTTPClient? = nil) {
        self.client = client ?? URLSessionHTTPClient()
    }

    public func fetch(with profileID: ProfileIdentifier) async throws -> Profile {
        let url = baseURL.appending(pathComponent: profileID.id)
        let request = await URLRequest(url: url).authorized()
        return try await fetch(with: request)
    }

    package func fetchAvatars(with token: String) async throws -> [Avatar] {
        let url = avatarsBaseURL
        let request = URLRequest(url: url).settingAuthorizationHeaderField(with: token)
        let (data, _) = try await client.fetchData(with: request)
        return try data.decode(keyDecodingStrategy: .convertFromSnakeCase)
    }

    package func fetchIdentity(token: String, profileID: ProfileIdentifier) async throws -> ProfileIdentity {
        guard let url = URL(string: identitiesBaseURL + profileID.id) else {
            throw APIError.requestError(reason: .errorCreatingURL)
        }

        let request = URLRequest(url: url).settingAuthorizationHeaderField(with: token)
        let (data, _) = try await client.fetchData(with: request)
        return try data.decode(keyDecodingStrategy: .convertFromSnakeCase)
    }

    package func selectAvatar(token: String, profileID: ProfileIdentifier, avatarID: String) async throws -> ProfileIdentity {
        guard let url = selectAvatarBaseURL(with: profileID) else {
            throw APIError.requestError(reason: .errorCreatingURL)
        }

        var request = URLRequest(url: url).settingAuthorizationHeaderField(with: token)
        request.httpMethod = "POST"
        request.httpBody = try SelectAvatarBody(avatarId: avatarID).data
        let (data, _) = try await client.performDataTask(with: request)
        return try data.decode(keyDecodingStrategy: .convertFromSnakeCase)
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

package struct ProfileIdentity: Decodable, Sendable {
    package let emailHash: String
    package let rating: String
    package let imageId: String
    package let imageUrl: String
}

package struct Avatar: Decodable, Sendable {
    private let imageId: String
    private let imageUrl: String

    package var id: String {
        imageId
    }

    package var url: String {
        "https://gravatar.com\(imageUrl)?size=256"
    }
}

private struct SelectAvatarBody: Encodable, Sendable {
    private let avatarId: String

    init(avatarId: String) {
        self.avatarId = avatarId
    }

    var data: Data {
        get throws {
            let encoder = JSONEncoder()
            encoder.keyEncodingStrategy = .convertToSnakeCase
            return try encoder.encode(self)
        }
    }
}
