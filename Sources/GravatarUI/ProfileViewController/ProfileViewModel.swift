import Foundation
import Gravatar

public protocol ProfileFetching {
    func fetch(with profileID: ProfileIdentifier) async throws -> UserProfile
}

extension ProfileService: ProfileFetching { }

@MainActor
public class ProfileViewModel {
    
    @Published var isLoading: Bool = false
    @Published var userProfile: UserProfile?
    @Published var profileFetchingError: ProfileServiceError?
    
    private let profileService: ProfileFetching
    
    init(profileService: ProfileFetching = ProfileService()) {
        self.profileService = profileService
    }
    
    func fetch(with profileID: ProfileIdentifier) async {
        defer {
            isLoading = false
        }
        do {
            isLoading = true
            self.userProfile = try await profileService.fetch(with: profileID)
            self.profileFetchingError = nil
        } catch let error as ProfileServiceError {
            self.profileFetchingError = error
        } catch {
            self.profileFetchingError = .responseError(reason: .unexpected(error))
        }
    }
}
