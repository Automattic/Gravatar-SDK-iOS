import Foundation
import Gravatar

@MainActor
public class ProfileViewModel {
    @Published public private(set) var isLoading: Bool = false
    @Published public private(set) var profileFetchingResult: Result<Profile, ProfileServiceError>?
    private let profileService: ProfileService

    public init(profileService: ProfileService = ProfileService()) {
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
