import Foundation

private let baseUrl = "https://gravatar.com/"

public enum GravatarProfileFetchResult {
    case success(UserProfile)
    case failure(ProfileServiceError)
}

/// A service to perform Profile related tasks.
public struct ProfileService {
    private let client: HTTPClient

    /// Creates a new `ProfileService`.
    ///
    /// Optionally, you can pass a custom type conforming to ``HTTPClient`` to gain control over networking tasks.
    /// - Parameter client: A type which will perform basic networking operations.
    public init(client: HTTPClient? = nil) {
        self.client = client ?? URLSessionHTTPClient()
    }

    /// Fetches a Gravatar user's profile information.
    /// - Parameters:
    ///   - email: The user account email.
    ///   - onCompletion: The completion handler to call when the fetch request is complete.
    public func fetchProfile(with email: String, onCompletion: @escaping ((_ result: GravatarProfileFetchResult) -> Void)) {
        Task {
            do {
                let profile = try await fetchProfile(for: email)
                onCompletion(.success(profile))
            } catch let error as ProfileServiceError {
                onCompletion(.failure(error))
            } catch {
                onCompletion(.failure(.responseError(reason: .unexpected(error))))
            }
        }
    }

    /// Fetches a Gravatar user's profile information, and delivers the user profile asynchronously.
    /// - Parameter email: The user account email.
    /// - Returns: An asynchronously-delivered user profile.
    public func fetchProfile(for email: String) async throws -> UserProfile {
        let url = try url(from: email.sha256() + ".json")
        return try await fetchProfile(with: URLRequest(url: url))
    }

    public func fetchProfile(with request: URLRequest) async throws -> UserProfile {
        do {
            let result: (data: Data, response: HTTPURLResponse) = try await client.fetchData(with: request)
            let fetchProfileResult = map(result.data, result.response)
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
}

extension ProfileService {
    /// Error thrown when URL can not be created with the given baseURL and path.
    struct CannotCreateURLFromGivenPath: Error {
        let baseURL: String
        let path: String
    }

    private func url(from path: String) throws -> URL {
        guard let url = URL(string: baseUrl + path) else {
            throw CannotCreateURLFromGivenPath(baseURL: baseUrl, path: path)
        }
        return url
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
