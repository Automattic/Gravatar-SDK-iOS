import Foundation

private let baseURL = URL(string: "https://api.gravatar.com/v3/profiles/")!

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
