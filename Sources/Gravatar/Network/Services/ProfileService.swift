import Foundation

public enum GravatarProfileFetchResult {
    case success(UserProfile)
    case failure(ProfileServiceError)
}

public struct ProfileService {
    private let client: HTTPClient

    public init(client: HTTPClient? = nil) {
        self.client = client ?? URLSessionHTTPClient()
    }

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

    public func fetchProfile(for email: String) async throws -> UserProfile {
        let path = email.sha256() + ".json"
        do {
            let result: FetchProfileResponse = try await client.fetchObject(from: path)
            let profile = result.entry[0]
            return profile
        } catch let error as HTTPClientError {
            throw ProfileServiceError.responseError(reason: error.map())
        } catch _ as CannotCreateURLFromGivenPath {
            throw ProfileServiceError.requestError(reason: .urlInitializationFailed)
        } catch {
            throw ProfileServiceError.responseError(reason: .unexpected(error))
        }
    }
}
