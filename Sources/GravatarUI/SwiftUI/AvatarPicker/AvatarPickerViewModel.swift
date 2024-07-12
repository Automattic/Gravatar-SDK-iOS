import Foundation
import SwiftUI

@MainActor
class AvatarPickerViewModel: ObservableObject {
    private let profileService: ProfileService = .init()
    private var email: Email?
    private var authToken: String?
    @Published private(set) var avatarImageModels: [AvatarImageModel]?
    @Published private(set) var selectedImageID: String?
    @Published private(set) var avatarFetchingError: Error?
    @Published private(set) var isAvatarsLoading: Bool = false
    @Published private(set) var selectedAvatarFetchingError: Error?

    init(email: Email, authToken: String) {
        self.email = email
        self.authToken = authToken
    }

    /// Internal init for previewing purposes. Do not make this public.
    init(avatarImageModels: [AvatarImageModel], selectedImageID: String? = nil) {
        self.avatarImageModels = avatarImageModels
        self.selectedImageID = selectedImageID
    }

    func fetchAvatars() async {
        guard let authToken else { return }
        do {
            isAvatarsLoading = true
            let images = try await profileService.fetchAvatars(with: authToken)
            avatarFetchingError = nil
            var avatarModels: [AvatarImageModel] = []
            for image in images {
                avatarModels.append(AvatarImageModel(id: image.id, source: .remote(url: image.url)))
            }
            avatarImageModels = avatarModels
            isAvatarsLoading = false
        } catch {
            avatarFetchingError = error
            avatarImageModels = nil
            isAvatarsLoading = false
        }
    }

    func fetchIdentity() async {
        guard let authToken, let email else { return }
        do {
            let identity = try await profileService.fetchIdentity(token: authToken, profileID: .email(email))
            selectedAvatarFetchingError = nil
            selectedImageID = identity.imageId
        } catch {
            selectedAvatarFetchingError = error
            selectedImageID = nil
        }
    }

    var emptyResult: Bool {
        if avatarFetchingError == nil, let avatars = avatarImageModels, avatars.count == 0 {
            return true
        }
        return false
    }

    func update(email: String) {
        self.email = .init(email)
        Task {
            await fetchIdentity()
        }
    }

    func update(authToken: String) {
        self.authToken = authToken
        refresh()
    }

    func refresh() {
        Task {
            await fetchAvatars()
            await fetchIdentity()
        }
    }
}
