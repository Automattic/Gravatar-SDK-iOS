import Foundation
import OpenAPIRuntime
import OpenAPIURLSession

public enum GravatarProfileFetchResult {
    case success(UserProfile)
    case failure(APIError)
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
            } catch let error as APIError {
                onCompletion(.failure(error))
            } catch {
                onCompletion(.failure(APIError.other(error)))
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
            throw APIError.invalidServerURL
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
                throw APIError.invalidHTTPStatusCode(APIErrorCode.notFound)
            case .tooManyRequests(_):
                throw APIError.invalidHTTPStatusCode(APIErrorCode.tooManyRequests)
            case .internalServerError(_):
                throw APIError.invalidHTTPStatusCode(APIErrorCode.internalServerError)
            case .undocumented(statusCode: let statusCode, _):
                throw APIError.invalidHTTPStatusCode(statusCode)
            }
        } catch {
            throw error.map()
        }
    }
}
