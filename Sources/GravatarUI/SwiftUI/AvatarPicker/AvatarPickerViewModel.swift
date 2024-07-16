import Foundation
import SwiftUI

@MainActor
class AvatarPickerViewModel: ObservableObject {
    private let profileService: ProfileService = .init()
    private var email: Email?
    private var authToken: String?
    @Published private(set) var modelState: ModelState?
    @Published private(set) var selectedImageID: String?
    @Published private(set) var isAvatarsLoading: Bool = false
    @Published private(set) var selectedAvatarFetchingError: Error?

    init(email: Email, authToken: String) {
        self.email = email
        self.authToken = authToken
    }

    /// Internal init for previewing purposes. Do not make this public.
    init(avatarImageModels: [AvatarImageModel], selectedImageID: String? = nil) {
        self.selectedImageID = selectedImageID
        self.modelState = .models(avatarImageModels)
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
            modelState = .models(avatarModels)
            isAvatarsLoading = false
        } catch {
            modelState = .error(error)
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

extension AvatarPickerViewModel {
    enum ModelState {
        case models([AvatarImageModel])
        case error(Error)

        func isEmpty() -> Bool {
            switch self {
            case .models(let models):
                models.isEmpty
            default:
                false
            }
        }
    }
}
