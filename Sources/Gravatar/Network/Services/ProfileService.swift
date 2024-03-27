import Foundation

private let baseURL = "https://gravatar.com/"

public enum GravatarProfileFetchResult {
    case success(UserProfile)
    case failure(ProfileServiceError)
}

/// A service to perform Profile related tasks.
public struct ProfileService: ProfileFetching {
    private let client: HTTPClient

    /// Creates a new `ProfileService`.
    ///
    /// Optionally, you can pass a custom type conforming to ``HTTPClient`` to gain control over networking tasks.
    /// - Parameter client: A type which will perform basic networking operations.
    public init(client: HTTPClient? = nil) {
        self.client = client ?? URLSessionHTTPClient()
    }

    public func fetch(withEmail email: String) async throws -> UserProfile {
        try await fetch(withPath: email.sha256())
    }

    public func fetch(withHash hash: String) async throws -> UserProfile {
        try await fetch(withPath: hash)
    }

    public func fetch(withUserName userName: String) async throws -> UserProfile {
        try await fetch(withPath: userName)
    }
}

extension ProfileService {
    /// Error thrown when URL can not be created with the given baseURL and path.
    struct CannotCreateURLFromGivenPath: Error {
        let baseURL: String
        let path: String
    }

    private func url(from path: String) throws -> URL {
        guard let url = URL(string: baseURL + path) else {
            throw CannotCreateURLFromGivenPath(baseURL: baseURL, path: path)
        }
        return url
    }

    private func fetch(withPath path: String) async throws -> UserProfile {
        let url = try url(from: path + ".json")
        return try await fetch(with: URLRequest(url: url))
    }

    private func fetch(with request: URLRequest) async throws -> UserProfile {
        do {
            let (data, response) = try await client.fetchData(with: request)
            let fetchProfileResult = map(data, response)
            switch fetchProfileResult {
            case .success(let profile):
                return profile
            case .failure(let error):
                throw error
            }
        } catch let error as HTTPClientError {
            throw ProfileServiceError.responseError(reason: error.map())
        }
    }

    private func map(_ data: Data, _: HTTPURLResponse) -> Result<UserProfile, ProfileServiceError> {
        do {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            let root = try decoder.decode(Root.self, from: data)
            let profile = try profile(from: root.entry)
            return .success(profile)
        } catch let error as HTTPClientError {
            return .failure(.responseError(reason: error.map()))
        } catch _ as ProfileService.CannotCreateURLFromGivenPath {
            return .failure(.requestError(reason: .urlInitializationFailed))
        } catch let error as ProfileServiceError {
            return .failure(error)
        } catch _ as DecodingError {
            return .failure(.noProfileInResponse)
        } catch {
            return .failure(.responseError(reason: .unexpected(error)))
        }
    }

    private func profile(from profiles: [UserProfile]) throws -> UserProfile {
        guard let profile = profiles.first else {
            throw ProfileServiceError.noProfileInResponse
        }

        return profile
    }
}
