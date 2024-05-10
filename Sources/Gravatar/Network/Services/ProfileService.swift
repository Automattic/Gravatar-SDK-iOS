import Foundation
import OpenAPIRuntime
import OpenAPIURLSession

public enum GravatarProfileFetchResult {
    case success(UserProfile)
    case failure(ProfileServiceError)
}

/// A service to perform Profile related tasks.
public struct ProfileService: ProfileFetching {
    let session: URLSession

    /// Creates a new `ProfileService`.
    ///
    public init(session: URLSession = .shared) {
        self.session = session
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

    public func fetch(with profileID: ProfileIdentifier) async throws -> UserProfile {
        try await fetch(with: profileID.id)
    }
}

extension ProfileService {
    private func openApiClient() throws -> Client {
        do {
            return Client(
                serverURL: try Servers.server1(),
                transport: URLSessionTransport(configuration: .init(session: session))
            )
        } catch {
            throw ProfileServiceError.requestError(reason: .invalidServerURL)
        }
    }

    private func fetch(with profileID: String) async throws -> UserProfile {
        let openApiClient = try openApiClient()
        do {
            let output = try await openApiClient.getProfileById(.init(path: .init(profileIdentifier: profileID)))

            switch output {
            case .ok(let response):
                let profile = try response.body.json
                return UserProfile(profile: profile)
            case .notFound(_):
                throw ProfileServiceError.responseError(reason: .invalidHTTPStatusCode(code: 404))
            case .tooManyRequests(_):
                throw ProfileServiceError.responseError(reason: .invalidHTTPStatusCode(code: 429))
            case .internalServerError(_):
                throw ProfileServiceError.responseError(reason: .invalidHTTPStatusCode(code: 500))
            case .undocumented(statusCode: let statusCode, _):
                throw ProfileServiceError.responseError(reason: .invalidHTTPStatusCode(code: statusCode))
            }
        } catch let error as ClientError {
            throw ProfileServiceError.responseError(reason: .unexpected(error.underlyingError))
        } catch {
            throw ProfileServiceError.responseError(reason: .unexpected(error))
        }
    }
}
