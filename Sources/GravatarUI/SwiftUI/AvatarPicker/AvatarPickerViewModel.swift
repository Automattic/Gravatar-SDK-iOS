import Foundation
import SwiftUI

@MainActor
class AvatarPickerViewModel: ObservableObject {
    private let profileService: ProfileService = .init()
    private var email: Email
    private var authToken: String
    @Published private(set) var avatarsResult: Result<[AvatarImageModel], Error>?
    @Published private(set) var currentAvatarResult: Result<String, Error>?
    @Published private(set) var isAvatarsLoading: Bool = false

    init(email: Email, authToken: String) {
        self.email = email
        self.authToken = authToken
    }

    /// Internal init for previewing purposes. Do not make this public.
    init(avatarImageModels: [AvatarImageModel], selectedImageID: String? = nil) {
        email = .init("")
        authToken = ""
        if let selectedImageID {
            self.currentAvatarResult = .success(selectedImageID)
        } else {
            self.currentAvatarResult = nil
        }
        self.avatarsResult = .success(avatarImageModels)
    }

    func fetchAvatars() async {
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

    func fetchIdentity() async {
        do {
            let identity = try await profileService.fetchIdentity(token: authToken, profileID: .email(email))
            currentAvatarResult = .success(identity.imageId)
        } catch {
            currentAvatarResult = .failure(error)
        }
    }

    func upload(_ image: UIImage) async {
        let localImageModel = AvatarImageModel(id: "new", source: AvatarImageModel.Source.local(image: image)).togglingLoading()
        if case .success(let avatarImageModels) = avatarsResult {
            let newList = [localImageModel] + avatarImageModels
            avatarsResult = .success(newList)
        }

        let service = AvatarService()
        do {
            let response = try await service.upload(image, email: email, accessToken: authToken)
            await fetchAvatars()
            await fetchIdentity()
        } catch {
            avatarsResult = .failure(error)
        }
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
