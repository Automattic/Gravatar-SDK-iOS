import Foundation
import Gravatar

public protocol ProfileFetching {
    func fetch(with profileID: ProfileIdentifier) async throws -> UserProfile
}

extension ProfileService: ProfileFetching {}

@MainActor
public class ProfileViewModel {
    @Published var isLoading: Bool = false
    @Published var profileFetchingResult: Result<UserProfile, ProfileServiceError>?
    private let profileService: ProfileFetching

    public init(profileService: ProfileFetching = ProfileService()) {
        self.profileService = profileService
    }

    public func fetchProfile(profileIdentifier: ProfileIdentifier) async {
        defer {
            isLoading = false
        }
        do {
            isLoading = true
            profileFetchingResult = try await .success(profileService.fetch(with: profileIdentifier))
        } catch let error as ProfileServiceError {
            profileFetchingResult = .failure(error)
        } catch {
            profileFetchingResult = .failure(.responseError(reason: .unexpected(error)))
        }
    }

    public func clear() {
        profileFetchingResult = nil
    }
}
