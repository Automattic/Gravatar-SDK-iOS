import Foundation
import Gravatar

public protocol ProfileFetching {
    func fetch(with profileID: ProfileIdentifier) async throws -> UserProfile
}

extension ProfileService: ProfileFetching {}

@MainActor
public class ProfileViewModel {
    @Published var isLoading: Bool = false
    @Published var userProfile: UserProfile?
    @Published var profileFetchingError: ProfileServiceError?
    public var profileIdentifier: ProfileIdentifier?
    private let profileService: ProfileFetching

    public init(profileService: ProfileFetching = ProfileService(), profileIdentifier: ProfileIdentifier? = nil) {
        self.profileService = profileService
        self.profileIdentifier = profileIdentifier
    }

    public func fetchProfile() async {
        guard let profileIdentifier else { return }
        defer {
            isLoading = false
        }
        do {
            isLoading = true
            self.userProfile = try await profileService.fetch(with: profileIdentifier)
            self.profileFetchingError = nil
        } catch let error as ProfileServiceError {
            self.profileFetchingError = error
        } catch {
            self.profileFetchingError = .responseError(reason: .unexpected(error))
        }
    }
}
