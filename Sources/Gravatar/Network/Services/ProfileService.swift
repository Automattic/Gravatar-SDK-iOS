import Foundation

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
    public func fetchProfile(for email: String) async throws -> GravatarProfile {
        let path = email.sha256() + ".json"
        do {
            let result: FetchProfileResponse = try await client.fetchObject(from: path)
            guard let profile = result.entry.first else {
                throw ProfileServiceError.noProfileInResponse
            }
            return GravatarProfile(with: profile)
        } catch let error as HTTPClientError {
            throw ProfileServiceError.responseError(reason: error.map())
        } catch _ as CannotCreateURLFromGivenPath {
            throw ProfileServiceError.requestError(reason: .urlInitializationFailed)
        } catch let error as ProfileServiceError {
            throw error
        } catch {
            throw ProfileServiceError.responseError(reason: .unexpected(error))
        }
    }
}
