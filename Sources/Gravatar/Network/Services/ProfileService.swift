import Foundation

private let baseURL = URL(string: "https://api.gravatar.com/v3/profiles/")!
private let avatarsBaseURLComponents = URLComponents(string: "https://api.gravatar.com/v3/me/avatars")!
private let meProfileURL = URL(string: "https://api.gravatar.com/v3/me/profile")!

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

    /// Fetches profile information for the authenticated user. Profile is created if it doesn't exist yet.
    public func fetchOwnProfile(token: String) async throws -> Profile {
        var request = URLRequest(url: meProfileURL).settingAuthorizationHeaderField(with: token)
        request.httpMethod = "GET"
        return try await fetch(with: request)
    }

    /// Fetch previously uploaded avatars for the given profile.
    /// - Parameters:
    ///   - id: The profile ID of the user.
    ///   - token: Gravatar OAuth2 token.
    /// - Returns: List of avatars the user has uploaded so far.
    public func fetchAvatars(profileID id: ProfileIdentifier, token: String) async throws -> [AvatarDetails] {
        do {
            guard let url = avatarsBaseURLComponents.settingQueryItems([.init(name: "selected_email_hash", value: id.id)]).url else {
                throw APIError.requestError(reason: .urlInitializationFailed)
            }
            let request = URLRequest(url: url).settingAuthorizationHeaderField(with: token)
            let (data, _) = try await client.data(with: request)
            let avatars: [Avatar] = try data.decode()
            return avatars
        } catch {
            throw error.apiError()
        }
    }

    /// Sets the user's public avatar with one of the previously uploaded avatars.
    /// - Parameters:
    ///   - profileID: The profile ID of the user.
    ///   - token: Gravatar OAuth2 token.
    ///   - imageID: ID of the avatar to be set as public avatar returned from the `/v3/me/avatars` endpoint. See: ``AvatarDetails/imageID``.
    /// - Returns: The details of the new avatar.
    public func setPublicAvatar(profileID: ProfileIdentifier, token: String, imageID: ImageID) async throws -> AvatarDetails {
        guard let url = selectAvatarBaseURL(with: imageID) else {
            throw APIError.requestError(reason: .urlInitializationFailed)
        }

        do {
            var request = URLRequest(url: url).settingAuthorizationHeaderField(with: token)
            request.httpMethod = "POST"
            request.httpBody = try SelectAvatarBody(emailHash: profileID.id).data
            let (data, _) = try await client.data(with: request)
            let avatar: Avatar = try data.decode()
            return avatar
        } catch {
            throw error.apiError()
        }
    }

    /// Update profile information for the authenticated user
    ///
    /// Updates the profile information for the authenticated user. Only a subset of `Profile` fields are available for supported, so only the provided fields
    /// will be updated. To unset a field, set it explicitly to an empty string.
    ///
    /// - Parameters:
    ///   - props: The subset of data available for update. Only the provided fields will be updated.
    ///   - token: Gravatar OAuth2 token.
    /// - Returns: An asynchronously-delivered user profile with the fields updated.
    public func updateProfile(with props: UpdateProfileRequest, token: String) async throws -> Profile {
        var request = URLRequest(url: meProfileURL).settingAuthorizationHeaderField(with: token)
        request.httpMethod = "PATCH"
        request.httpBody = try? JSONEncoder().encode(props)
        let response = try await fetch(with: request)
        return response
    }
}

extension ProfileService {
    private func fetch(with request: URLRequest) async throws -> Profile {
        do {
            let (data, _) = try await client.data(with: request)
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
