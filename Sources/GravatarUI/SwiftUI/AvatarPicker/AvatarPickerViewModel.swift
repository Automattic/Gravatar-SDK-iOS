import Foundation
import Gravatar
import SwiftUI

@MainActor
class AvatarPickerViewModel: ObservableObject {
    private let profileService: ProfileService = .init()
    private(set) var email: Email? {
        didSet {
            guard let email else {
                avatarIdentifier = nil
                return
            }
            avatarIdentifier = .email(email)
        }
    }

    private var avatarSelectionTask: Task<Void, Never>?
    private var authToken: String?
    private var selectedAvatarResult: Result<String, Error>? {
        didSet {
            if selectedAvatarResult?.value() != nil {
                updateSelectedAvatarURL()
            }
        }
    }

    @Published var selectedAvatarURL: URL?
    @Published private(set) var gridResponseStatus: Result<Void, Error>?

    let grid: AvatarGridModel = .init(avatars: [])

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
    @ObservedObject var toastManager: ToastManager = .init()

    init(email: Email, authToken: String) {
        self.email = email
        avatarIdentifier = .email(email)
        self.authToken = authToken
    }

    /// Internal init for previewing purposes. Do not make this public.
    init(avatarImageModels: [AvatarImageModel], selectedImageID: String? = nil, profileModel: ProfileSummaryModel? = nil) {
        if let selectedImageID {
            self.selectedAvatarResult = .success(selectedImageID)
        }

        grid.setAvatars(avatarImageModels)
        grid.selectAvatar(withID: selectedImageID)
        gridResponseStatus = .success(())

        if let profileModel {
            self.profileResult = .success(profileModel)
            self.profileModel = .init(displayName: profileModel.displayName, location: profileModel.location, profileURL: profileModel.profileURL)
            switch profileModel.avatarIdentifier {
            case .email(let email):
                self.email = email
            default:
                break
            }
        }
    }

    func selectAvatar(with id: String) {
        guard
            let email,
            let authToken,
            grid.selectedAvatar?.id != id,
            grid.model(with: id)?.state == .loaded
        else { return }

        avatarSelectionTask?.cancel()

        avatarSelectionTask = Task {
            await postAvatarSelection(with: id, authToken: authToken, identifier: .email(email))
        }
    }

    func postAvatarSelection(with avatarID: String, authToken: String, identifier: ProfileIdentifier) async {
        defer {
            grid.setState(to: .loaded, onAvatarWithID: avatarID)
        }
        grid.selectAvatar(withID: avatarID)
        grid.setState(to: .loading, onAvatarWithID: avatarID)

        do {
            let response = try await profileService.selectAvatar(token: authToken, profileID: identifier, avatarID: avatarID)
            toastManager.showToast(Localized.avatarUpdateSuccess, type: .info)

            selectedAvatarResult = .success(response.imageId)
        } catch APIError.responseError(let reason) where reason.cancelled {
            // NoOp.
        } catch APIError.responseError(let .invalidHTTPStatusCode(response, errorPayload)) {
            toastManager.showToast(errorPayload?.message ?? Localized.avatarUpdateFail, type: .error)
            // Reconstruct the original error so we can pass it to the handler
            let thrownError = APIError.responseError(reason: .invalidHTTPStatusCode(response: response, errorPayload: errorPayload))
            handleSelectionError(error: thrownError)
        } catch {
            toastManager.showToast(Localized.avatarUpdateFail, type: .error)
            grid.selectAvatar(withID: selectedAvatarResult?.value())
        }
    }

    func fetchAvatars() async {
        guard let authToken, let email else { return }

        do {
            isAvatarsLoading = true
            let images = try await profileService.fetchAvatars(with: authToken, id: .email(email))
            grid.setAvatars(images.map(AvatarImageModel.init))
            if let selectedAvatar = grid.selectedAvatar {
                selectedAvatarURL = selectedAvatar.url
                selectedAvatarResult = .success(selectedAvatar.id)
            }
            isAvatarsLoading = false
            gridResponseStatus = .success(())
        } catch {
            gridResponseStatus = .failure(error)
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

    func upload(_ image: UIImage, shouldSquareImage: Bool) async {
        guard let authToken else { return }

        let squareImage = shouldSquareImage ? image.squared() : image
        let localID = UUID().uuidString

        let localImageModel = AvatarImageModel(id: localID, source: .local(image: squareImage), state: .loading)
        grid.append(localImageModel)

        await doUpload(squareImage: squareImage, localID: localID, accessToken: authToken)
    }

    func retryUpload(of localID: String) async {
        guard let authToken,
              let model = grid.avatars.first(where: { $0.id == localID }),
              let localImage = model.localUIImage
        else {
            return
        }
        grid.setState(to: .loading, onAvatarWithID: localID)
        await doUpload(squareImage: localImage, localID: localID, accessToken: authToken)
    }

    func deleteFailed(_ id: String) {
        grid.deleteModel(id)
    }

    private func doUpload(squareImage: UIImage, localID: String, accessToken: String) async {
        let service = AvatarService()
        do {
            let avatar = try await service.upload(squareImage, accessToken: accessToken)
            ImageCache.shared.setEntry(.ready(squareImage), for: avatar.url)

            let newModel = AvatarImageModel(id: avatar.id, source: .remote(url: avatar.url))
            grid.replaceModel(withID: localID, with: newModel)
        } catch ImageUploadError.responseError(reason: let .invalidHTTPStatusCode(response, errorPayload)) where response.statusCode == 400 {
            // If the status code is 400 then it means we got a validation error about this image and the operation is not suitable for retrying.
            handleUploadError(
                imageID: localID,
                squareImage: squareImage,
                supportsRetry: false,
                errorMessage: errorPayload?.message ?? Localized.genericUploadError
            )
        } catch ImageUploadError.responseError(reason: let reason) where reason.urlSessionErrorLocalizedDescription != nil {
            handleUploadError(
                imageID: localID,
                squareImage: squareImage,
                supportsRetry: true,
                errorMessage: reason.urlSessionErrorLocalizedDescription ?? Localized.genericUploadError
            )
        } catch {
            handleUploadError(
                imageID: localID,
                squareImage: squareImage,
                supportsRetry: true,
                errorMessage: Localized.genericUploadError
            )
        }
    }

    private func handleUploadError(imageID: String, squareImage: UIImage, supportsRetry: Bool, errorMessage: String) {
        let newModel = AvatarImageModel(
            id: imageID,
            source: .local(image: squareImage),
            state: .error(supportsRetry: supportsRetry, errorMessage: errorMessage)
        )
        grid.replaceModel(withID: imageID, with: newModel)
    }

    private func handleSelectionError(error: Error) {
        self.grid.setAvatars([])
        self.gridResponseStatus = .failure(error)
    }

    private func updateSelectedAvatarURL() {
        guard let selectedID = selectedAvatarResult?.value() else { return }
        grid.selectAvatar(withID: selectedID)
        selectedAvatarURL = grid.selectedAvatar?.url
    }

    func update(email: String) {
        self.email = .init(email)
        Task {
            // parallel child tasks
            async let profile: () = fetchProfile()

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
            async let profile: () = fetchProfile()

            // We need to await them otherwise network requests can be cancelled.
            await avatars
            await profile
        }
    }
}

extension AvatarPickerViewModel {
    private enum Localized {
        static let genericUploadError = SDKLocalizedString(
            "AvatarPickerViewModel.Upload.Error.message",
            value: "Oops, there was an error uploading the image.",
            comment: "A generic error message to show on an error dialog when the upload fails."
        )
        static let avatarUpdateSuccess = SDKLocalizedString(
            "AvatarPickerViewModel.Update.Success",
            value: "Avatar updated! It may take a few minutes to appear everywhere.",
            comment: "This confirmation message shows when the user picks a different avatar."
        )
        static let avatarUpdateFail = SDKLocalizedString(
            "AvatarPickerViewModel.Update.Fail",
            value: "Oops, something didn't quite work out while trying to change your avatar.",
            comment: "This error message shows when the user attempts to pick a different avatar and fails."
        )
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

extension UIImage {
    fileprivate func squared() -> UIImage {
        let (height, width) = (size.height, size.width)
        guard height != width else {
            return self
        }
        let squareSide = {
            // If there's a side difference of 1~2px in an image smaller then (around) 100px, this will return false.
            if width != height && (abs(width - height) / min(width, height)) < 0.02 {
                // Aspect fill
                return min(height, width)
            }
            // Aspect fit
            return max(height, width)
        }()

        let squareSize = CGSize(width: squareSide, height: squareSide)
        let imageOrigin = CGPoint(x: (squareSide - width) / 2, y: (squareSide - height) / 2)

        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        return UIGraphicsImageRenderer(size: squareSize, format: format).image { context in
            UIColor.black.setFill()
            context.fill(CGRect(origin: .zero, size: squareSize))
            draw(in: CGRect(origin: imageOrigin, size: size))
        }
    }
}

extension AvatarImageModel {
    init(with avatar: Avatar) {
        id = avatar.id
        source = .remote(url: avatar.url)
        state = .loaded
        isSelected = avatar.isSelected
    }
}
