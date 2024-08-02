import Foundation
import Gravatar
import SwiftUI

@MainActor
class AvatarPickerViewModel: ObservableObject {
    private let profileService: ProfileService = .init()
    private var email: Email? {
        didSet {
            guard let email else {
                avatarIdentifier = nil
                return
            }
            avatarIdentifier = .email(email)
        }
    }

    private var authToken: String?
    @Published private(set) var avatarsResult: Result<[AvatarImageModel], Error>?
    @Published private(set) var currentAvatarResult: Result<String, Error>?
    private var profileResult: Result<ProfileSummaryModel, Error>? {
        didSet {
            switch profileResult {
            case .success(let value):
                profileModel = .init(displayName: value.displayName, location: value.location, profileURL: value.profileURL)
            default:
                profileModel = nil
            }
        }
    }

    @Published var isProfileLoading: Bool = false
    @Published private(set) var isAvatarsLoading: Bool = false
    @Published var avatarIdentifier: AvatarIdentifier?
    @Published var profileModel: AvatarPickerProfileView.Model?

    init(email: Email, authToken: String) {
        self.email = email
        avatarIdentifier = .email(email)
        self.authToken = authToken
    }

    /// Internal init for previewing purposes. Do not make this public.
    init(avatarImageModels: [AvatarImageModel], selectedImageID: String? = nil, profileModel: ProfileSummaryModel? = nil) {
        if let selectedImageID {
            self.currentAvatarResult = .success(selectedImageID)
        } else {
            self.currentAvatarResult = nil
        }
        self.avatarsResult = .success(avatarImageModels)
        if let profileModel {
            self.profileResult = .success(profileModel)
        }
    }

    func fetchAvatars() async {
        guard let authToken else { return }
        do {
            isAvatarsLoading = true
            let images = try await profileService.fetchAvatars(with: authToken)
            var avatarModels: [AvatarImageModel] = []
            for image in images {
                avatarModels.append(AvatarImageModel(id: image.id, source: .remote(url: image.url)))
            }
            avatarsResult = .success(avatarModels)
            isAvatarsLoading = false
        } catch {
            avatarsResult = .failure(error)
            isAvatarsLoading = false
        }
    }

    func fetchProfile() async {
        guard let email else { return }
        do {
            isProfileLoading = true
            let profile = try await profileService.fetch(with: .email(email))
            profileResult = .success(profile)
            isProfileLoading = false
        } catch {
            profileResult = .failure(error)
            isProfileLoading = false
        }
    }

    func fetchIdentity() async {
        guard let authToken, let email else { return }
        do {
            let identity = try await profileService.fetchIdentity(token: authToken, profileID: .email(email))
            currentAvatarResult = .success(identity.imageId)
        } catch {
            currentAvatarResult = .failure(error)
        }
    }

    func update(email: String) {
        self.email = .init(email)
        Task {
            // parallel child tasks
            async let identity: () = fetchIdentity()
            async let profile: () = fetchProfile()

            await identity
            await profile
        }
    }

    func update(authToken: String) {
        self.authToken = authToken
        refresh()
    }

    func refresh() {
        Task {
            // We want them to be parallel child tasks so they don't wait each other.
            async let avatars: () = fetchAvatars()
            async let identity: () = fetchIdentity()
            async let profile: () = fetchProfile()

            // We need to await them otherwise network requests can be cancelled.
            await avatars
            await identity
            await profile
        }
    }
}

extension Result<[AvatarImageModel], Error> {
    func isEmpty() -> Bool {
        switch self {
        case .success(let models):
            models.isEmpty
        default:
            false
        }
    }
}
