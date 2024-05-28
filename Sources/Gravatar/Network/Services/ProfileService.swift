import Foundation

private let baseURL = URL(string: "https://api.gravatar.com/v3/profiles/")!

public enum GravatarProfileFetchResult: Sendable {
    case success(Profile)
    case failure(ProfileServiceError)
}

/// A service to perform Profile related tasks.
public struct ProfileService: ProfileFetching, Sendable {
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
    public func fetchProfile(with profileID: ProfileIdentifier, onCompletion: @Sendable @escaping (_ result: GravatarProfileFetchResult) -> Void) {
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
        let request = await URLRequest(url: url).authorized(with: Configuration.shared.apiKey)
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

    private func map(_ data: Data, _: HTTPURLResponse) -> Result<Profile, ProfileServiceError> {
        do {
            let profile = try JSONDecoder().decode(Profile.self, from: data)
            return .success(profile)
        } catch let error as HTTPClientError {
            return .failure(.responseError(reason: error.map()))
        } catch let error as ProfileServiceError {
            return .failure(error)
        } catch _ as DecodingError {
            return .failure(.noProfileInResponse)
        } catch {
            return .failure(.responseError(reason: .unexpected(error)))
        }
    }
}

extension URLRequest {
    private enum HeaderField: String {
        case authorization = "Authorization"
    }

    fileprivate func authorized(with key: String?) -> URLRequest {
        guard let key else { return self }
        let bearerKey = "Bearer \(key)"
        var copy = self
        copy.setValue(bearerKey, forHTTPHeaderField: HeaderField.authorization.rawValue)
        return copy
    }
}
