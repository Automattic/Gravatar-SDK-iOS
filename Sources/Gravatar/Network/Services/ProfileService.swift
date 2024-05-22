import Foundation

private let baseURL = URL(string: "https://api.gravatar.com/v3/profiles/")!

public enum GravatarProfileFetchResult {
    case success(Profile)
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

    /// Fetches a Gravatar user's profile information.
    /// - Parameters:
    ///   - profileID: A `ProfileIdentifier` for the Gravatar profile
    ///   - onCompletion: The completion handler to call when the fetch request is complete.
    public func fetchProfile(with profileID: ProfileIdentifier, onCompletion: @escaping ((_ result: GravatarProfileFetchResult) -> Void)) {
        Task {
            do {
                let profile = try await fetch(with: profileID)
                onCompletion(.success(profile))
            } catch let error as ProfileServiceError {
                onCompletion(.failure(error))
            } catch {
                onCompletion(.failure(.responseError(reason: .unexpected(error))))
            }
        }
    }

    public func fetch(with profileID: ProfileIdentifier) async throws -> Profile {
        let url = baseURL.appending(pathComponent: profileID.id)
        let request = URLRequest(url: url)
        // TODO: Add token to headers
        return try await fetch(with: request)
    }
}

extension ProfileService {
    private func fetch(with request: URLRequest) async throws -> Profile {
        do {
            let (data, response) = try await client.fetchData(with: request)
            let profileResult: Result<Profile, ProfileServiceError> = map(data, response)
            switch profileResult {
            case .success(let success):
                return success
            case .failure(let failure):
                throw failure
            }
        } catch let error as HTTPClientError {
            throw ProfileServiceError.responseError(reason: error.map())
        }
    }

    private func map<UserType: Decodable>(_ data: Data, _: HTTPURLResponse) -> Result<UserType, ProfileServiceError> {
        do {
            let profile = try JSONDecoder().decode(UserType.self, from: data)
            return .success(profile)
        } catch let error as HTTPClientError {
            return .failure(.responseError(reason: error.map()))
        } catch let error as ProfileServiceError {
            return .failure(error)
        } catch let error as DecodingError {
            print(error)
            return .failure(.noProfileInResponse)
        } catch {
            return .failure(.responseError(reason: .unexpected(error)))
        }
    }
}
