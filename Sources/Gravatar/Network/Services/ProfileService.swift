import Foundation

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
                onCompletion(.failure(.unexpected(error)))
            }
        }
    }

    public func fetchProfile(for email: String) async throws -> GravatarProfile {
        let path = try email.sha256() + ".json"
        let result: FetchProfileResponse = try await client.fetchObject(from: path)
        let profile = result.entry[0]
        return GravatarProfile(with: profile)
    }
}