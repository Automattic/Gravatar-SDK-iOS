import Foundation

public struct ProfileService {
    private let client: HTTPClient

    public init(client: HTTPClient? = nil) {
        self.client = client ?? URLSessionHTTPClient()
    }

    public func fetchProfile(email: String, onCompletion: @escaping ((_ result: GravatarProfileFetchResult) -> Void)) {
        Task {
            do {
                let profile = try await fetchProfile(email: email)
                onCompletion(.success(profile))
            } catch {
                onCompletion(.failure(error))
            }
        }
    }

    public func fetchProfile(email: String) async throws -> GravatarProfile {
        let path = try email.sha256() + ".json"
        let result: FetchProfileResponse = try await client.fetchObject(from: path)
        let profile = result.entry[0]
        return GravatarProfile(with: profile)
    }
}
