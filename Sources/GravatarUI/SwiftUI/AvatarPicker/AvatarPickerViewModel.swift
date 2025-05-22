import Combine
import Foundation
import Gravatar
import SwiftUI

@MainActor
class AvatarPickerViewModel: ObservableObject {
    enum ModelRefresh {
        case avatarPickerModel
        case aboutEditorModel
        case all
    }

    private let profileService: ProfileService
    private let avatarService: AvatarService
    private let imageDownloader: ImageDownloader

    private(set) var email: Email {
        didSet {
            avatarIdentifier = .email(email)
        }
    }

    private var avatarSelectionTask: Task<AvatarDetails?, Never>?
    private var authToken: String?
    private var selectedAvatarResult: Result<String, Error>? {
        didSet {
            if selectedAvatarResult?.value() != nil {
                updateSelectedAvatarURL()
            }
        }
    }

    @Published var selectedAvatarURL: URL?
    @Published private(set) var backendSelectedAvatarURL: URL?
    @Published private(set) var gridResponseStatus: Result<Void, Error>?
    @Published private(set) var grid: AvatarGridModel = .init(avatars: [])
    @Published private(set) var profileResult: Result<Profile, Error>?

    @Published var isProfileLoading: Bool = false
    @Published private(set) var isAvatarsLoading: Bool = false
    @Published var avatarIdentifier: AvatarIdentifier?
    @Published var forceRefreshAvatar: Bool = false
    @Published var profileModel: AvatarPickerProfileViewModel?
    @Published var aboutInfoModel: AboutInfoModel = .init()

    @Published var isKeyboardPresented: Bool = false

    @Published var shouldDisplayNoSelectedAvatarWarning: Bool = false
    @ObservedObject var toastManager: ToastManager = .init()
    private var cancellables = Set<AnyCancellable>()

    var hasUnsavedChanges: Bool {
        guard let profile = profileResult?.value() else {
            return false
        }
        return !aboutInfoModel.hasEqualFields(than: profile)
    }

    init(
        email: Email,
        authToken: String?,
        profileService: ProfileService? = nil,
        avatarService: AvatarService? = nil,
        imageDownloader: ImageDownloader? = nil
    ) {
        self.email = email
        avatarIdentifier = .email(email)
        self.authToken = authToken
        self.profileService = profileService ?? ProfileService()
        self.avatarService = avatarService ?? AvatarService()
        self.imageDownloader = imageDownloader ?? ImageDownloadService()
        setupCombine()
    }

    /// Internal init for previewing purposes. Do not make this public.
    init(
        avatarImageModels: [AvatarImageModel],
        selectedImageID: String? = nil,
        profileModel: Profile? = nil,
        profileService: ProfileService? = nil,
        avatarService: AvatarService? = nil,
        imageDownloader: ImageDownloader? = nil
    ) {
        self.profileService = profileService ?? ProfileService()
        self.avatarService = avatarService ?? AvatarService()
        self.imageDownloader = imageDownloader ?? ImageDownloadService()

        if let selectedImageID {
            self.selectedAvatarResult = .success(selectedImageID)
        }

        self.email = .init("some@email.com")

        grid.setAvatars(avatarImageModels)
        grid.selectAvatar(withID: selectedImageID)
        gridResponseStatus = .success(())

        if let profileModel {
            self.profileResult = .success(profileModel)
            self.profileModel = .init(
                displayName: profileModel.displayName,
                location: profileModel.location,
                profileURL: profileModel.profileURL
            )
            switch profileModel.avatarIdentifier {
            case .email(let email):
                self.email = email
            default:
                break
            }
        }
        setupCombine()
    }

    private func setupCombine() {
        grid.$avatars
            .map {
                $0.filter { avatar in
                    avatar.state == .loaded
                }.count
            }
            .combineLatest($selectedAvatarURL)
            .map { loadedAvatarCount, selectedAvatarURL in
                // Determine if the warning should be displayed
                selectedAvatarURL == nil && loadedAvatarCount > 0
            }
            .assign(to: \.shouldDisplayNoSelectedAvatarWarning, on: self)
            .store(in: &cancellables)

        $profileResult.sink { [weak self] profileResult in
            switch profileResult {
            case .success(let updatedProfile):
                self?.profileModel = .init(
                    displayName: updatedProfile.displayName,
                    location: updatedProfile.location,
                    profileURL: updatedProfile.profileURL
                )
                self?.aboutInfoModel = updatedProfile.aboutModel()
            default:
                self?.profileModel = nil
            }
        }
        .store(in: &cancellables)
    }

    func selectAvatar(with id: String) async -> AvatarDetails? {
        guard
            let authToken,
            grid.selectedAvatar?.id != id,
            grid.model(with: id)?.state == .loaded
        else { return nil }

        avatarSelectionTask?.cancel()

        avatarSelectionTask = Task {
            await postAvatarSelection(with: id, authToken: authToken, identifier: .email(email))
        }

        return await avatarSelectionTask?.value
    }

    func fetchOriginalSizeAvatar(for avatar: AvatarImageModel) async -> UIImage? {
        guard let avatarURL = avatar.shareURL else { return nil }
        do {
            grid.setState(to: .loading, onAvatarWithID: avatar.id)
            let result = try await imageDownloader.fetchImage(with: avatarURL, forceRefresh: false, processingMethod: .common())
            grid.setState(to: .loaded, onAvatarWithID: avatar.id)
            return result.image
        } catch ImageFetchingError.responseError(reason: let reason) where reason.urlSessionErrorLocalizedDescription != nil {
            grid.setState(to: .loaded, onAvatarWithID: avatar.id)
            toastManager.showToast(reason.urlSessionErrorLocalizedDescription ?? Localized.avatarShareFail, type: .error)
        } catch {
            grid.setState(to: .loaded, onAvatarWithID: avatar.id)
            toastManager.showToast(Localized.avatarShareFail, type: .error)
        }
        return nil
    }

    func fetchAndSaveToFile(avatar: AvatarImageModel) async -> URL? {
        guard let image = await fetchOriginalSizeAvatar(for: avatar) else { return nil }
        do {
            return try image.saveToFile()
        } catch {
            toastManager.showToast(Localized.avatarShareFail, type: .error)
        }
        return nil
    }

    func postAvatarSelection(with avatarID: String, authToken: String, identifier: ProfileIdentifier) async -> AvatarDetails? {
        defer {
            grid.setState(to: .loaded, onAvatarWithID: avatarID)
        }
        grid.selectAvatar(withID: avatarID)
        grid.setState(to: .loading, onAvatarWithID: avatarID)

        do {
            let selectedAvatar = try await profileService.setPublicAvatar(profileID: identifier, token: authToken, imageID: avatarID)
            toastManager.showToast(Localized.avatarUpdateSuccess, type: .info)
            grid.replaceModel(withID: avatarID, with: .init(with: selectedAvatar))
            selectedAvatarResult = .success(selectedAvatar.imageID)
            return selectedAvatar
        } catch APIError.responseError(let reason) where reason.cancelled {
            // NoOp.
        } catch APIError.responseError(let .invalidHTTPStatusCode(response, errorPayload)) where response.statusCode == HTTPStatus.unauthorized.rawValue {
            handleUnrecoverableClientError(APIError.responseError(reason: .invalidHTTPStatusCode(response: response, errorPayload: errorPayload)))
        } catch {
            showToast(for: error, fallbackText: Localized.avatarUpdateFail)
            grid.selectAvatar(withID: selectedAvatarResult?.value())
        }
        return nil
    }

    func fetchAvatars() async {
        guard let authToken else { return }

        do {
            isAvatarsLoading = true
            let images = try await profileService.fetchAvatars(profileID: .email(email), token: authToken)
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
        do {
            isProfileLoading = true
            let profile: Profile = if let authToken {
                try await profileService.fetchOwnProfile(token: authToken)
            } else {
                // Fallback to the public profile endpoint if there's no token.
                try await profileService.fetch(with: .email(email))
            }
            profileResult = .success(profile)
            isProfileLoading = false
        } catch {
            profileResult = .failure(error)
            isProfileLoading = false
        }
    }

    func saveAboutInfo(for fields: AboutInfoField) async -> Profile? {
        guard let authToken else { return nil }
        do {
            let request = aboutInfoModel.updateProfileRequest(for: fields)
            let updatedProfile = try await profileService.updateProfile(with: request, token: authToken)
            self.profileResult = .success(updatedProfile)
            toastManager.showToast(Localized.profileUpdateSuccess, type: .info)
            return updatedProfile
        } catch APIError.responseError(let .invalidHTTPStatusCode(response, errorPayload))
            where response.statusCode == HTTPStatus.unauthorized.rawValue
        {
            handleUnrecoverableClientError(APIError.responseError(
                reason: .invalidHTTPStatusCode(
                    response: response,
                    errorPayload: errorPayload
                )
            ))
            return nil
        } catch {
            showToast(for: error, fallbackText: Localized.profileUpdateFail)
            return nil
        }
    }

    func upload(_ image: UIImage, shouldSquareImage: Bool) async {
        guard let authToken else { return }

        // SwiftUI doesn't update the UI if the grid is empty.
        // objectWillChange forces the update.
        objectWillChange.send()

        let localID = UUID().uuidString

        let localImageModel = AvatarImageModel(id: localID, source: .local(image: image), state: .loading, isSelected: false, rating: .general, altText: "")
        grid.append(localImageModel)

        await doUpload(squareImage: image, localID: localID, accessToken: authToken)
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
        _ = grid.deleteModel(id)
    }

    private func doUpload(squareImage: UIImage, localID: String, accessToken: String) async {
        do {
            let avatar = try await avatarService.upload(
                squareImage,
                accessToken: accessToken,
                selectionBehavior: .selectUploadedImageIfNoneSelected(for: email)
            )
            ImageCache.shared.setEntry(.ready(squareImage), for: avatar.imageURL)

            let newModel = AvatarImageModel(with: avatar)
            grid.replaceModel(withID: localID, with: newModel)

            if avatar.isSelected {
                grid.selectAvatar(withID: avatar.imageID)
                self.selectedAvatarURL = URL(string: avatar.imageURL)
                self.backendSelectedAvatarURL = URL(string: avatar.imageURL)
            }
        } catch ImageUploadError.responseError(reason: let .invalidHTTPStatusCode(response, errorPayload))
            where response.statusCode == HTTPStatus.badRequest.rawValue || response.statusCode == HTTPStatus.payloadTooLarge.rawValue
        {
            let message: String = {
                if response.statusCode == HTTPStatus.payloadTooLarge.rawValue {
                    // The error response comes back as an HTML document for 413, which is unexpected.
                    // Until BE starts to send the json, we'll handle 413 on the client side.
                    return Localized.imageTooBigError
                }
                return errorPayload?.message ?? Localized.genericUploadError
            }()
            // If the status code is 400 then it means we got a validation error about this image and the operation is not suitable for retrying.
            handleUploadError(
                imageID: localID,
                squareImage: squareImage,
                supportsRetry: false,
                errorMessage: message
            )
        } catch ImageUploadError.responseError(reason: let .invalidHTTPStatusCode(response, errorPayload))
            where response.statusCode == HTTPStatus.unauthorized.rawValue
        {
            // If the status code is 401 (unauthorized), then it means the token is not valid and we should prompt the user accordingly.
            handleUnrecoverableClientError(APIError.responseError(reason: .invalidHTTPStatusCode(response: response, errorPayload: errorPayload)))
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
        let storedModel = grid.model(with: imageID)
        let newModel = AvatarImageModel(
            id: imageID,
            source: .local(image: squareImage),
            state: .error(supportsRetry: supportsRetry, errorMessage: errorMessage),
            isSelected: false,
            rating: storedModel?.rating ?? .general,
            altText: storedModel?.altText ?? ""
        )
        grid.replaceModel(withID: imageID, with: newModel)
    }

    private func handleUnrecoverableClientError(_ error: Error) {
        self.grid.setAvatars([])
        self.gridResponseStatus = .failure(error)
        self.profileResult = .failure(error)
    }

    func showToast(for error: Error, fallbackText: String) {
        let message: String = switch error {
        case APIError.responseError(reason: let reason):
            reason.urlSessionErrorLocalizedDescription ?? fallbackText
        default:
            fallbackText
        }
        toastManager.showToast(message, type: .error)
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

    func update(authToken: String, modelToRefresh: ModelRefresh) {
        self.authToken = authToken
        refresh(modelToRefresh: modelToRefresh)
    }

    func refresh(modelToRefresh: ModelRefresh) {
        Task {
            await refresh(modelToRefresh: modelToRefresh)
        }
    }

    func refresh(modelToRefresh: ModelRefresh) async {
        switch modelToRefresh {
        case .avatarPickerModel:
            await fetchAvatars()
        case .aboutEditorModel:
            await fetchProfile()
        case .all:
            // We want them to be parallel child tasks so they don't wait each other.
            async let avatars: () = fetchAvatars()
            async let profile: () = fetchProfile()

            // We need to await them otherwise network requests can be cancelled.
            await avatars
            await profile
        }
    }

    @discardableResult
    func update(altText: String, for avatar: AvatarImageModel) async -> Bool {
        guard let token = self.authToken else { return false }
        do {
            let updatedAvatar = try await avatarService.updateAvatar(imageID: avatar.id, accessToken: token, altText: altText)
            withAnimation {
                grid.replaceModel(withID: avatar.id, with: .init(with: updatedAvatar))
            }
            return true
        } catch APIError.responseError(reason: let reason) where reason.urlSessionErrorLocalizedDescription != nil {
            handleError(message: reason.urlSessionErrorLocalizedDescription ?? Localized.avatarAltTextError)
        } catch {
            handleError(message: Localized.avatarAltTextError)
        }

        func handleError(message: String) {
            toastManager.showToast(message, type: .error)
        }

        return false
    }

    @discardableResult
    func update(rating: Rating, for avatar: AvatarImageModel) async -> Bool {
        guard let authToken else { return false }

        do {
            let updatedAvatar = try await avatarService.updateAvatar(
                imageID: avatar.id,
                accessToken: authToken,
                rating: rating
            )
            toastManager.showToast(Localized.avatarRatingUpdateSuccess, type: .info)
            withAnimation {
                grid.replaceModel(withID: avatar.id, with: .init(with: updatedAvatar))
            }
            return true
        } catch APIError.responseError(let reason) where reason.urlSessionErrorLocalizedDescription != nil {
            handleError(message: reason.urlSessionErrorLocalizedDescription ?? Localized.avatarRatingError)
        } catch {
            handleError(message: Localized.avatarRatingError)
        }

        func handleError(message: String) {
            toastManager.showToast(message, type: .error)
        }

        return false
    }

    func delete(_ avatar: AvatarImageModel) async -> Bool {
        guard let token = self.authToken else { return false }
        defer {
            selectedAvatarURL = grid.selectedAvatar?.url
        }
        let previouslySelectedAvatar = grid.selectedAvatar

        let deletedIndex = withAnimation {
            grid.deleteModel(avatar.id)
        }

        guard let deletedIndex else { return false }

        if selectedAvatarURL != grid.selectedAvatar?.url {
            selectedAvatarURL = grid.selectedAvatar?.url
        }

        return await postDeletion(
            of: avatar,
            token: token,
            deletingAvatarIndex: deletedIndex,
            previouslySelectedAvatar: previouslySelectedAvatar
        )
    }

    private func postDeletion(
        of avatar: AvatarImageModel,
        token: String,
        deletingAvatarIndex: Int,
        previouslySelectedAvatar: AvatarImageModel?
    ) async -> Bool {
        do {
            try await avatarService.delete(imageID: avatar.id, accessToken: token)
            return true
        } catch APIError.responseError(let reason) where reason.httpStatusCode == 404 {
            return true // no-op. We delete a not-found avatar from the UI.
        } catch APIError.responseError(reason: let reason) where reason.urlSessionErrorLocalizedDescription != nil {
            handleError(message: reason.urlSessionErrorLocalizedDescription ?? Localized.avatarDeletionError)
        } catch {
            handleError(message: Localized.avatarDeletionError)
        }
        return false

        func handleError(message: String) {
            withAnimation {
                grid.insert(avatar, at: deletingAvatarIndex)
                grid.selectAvatar(previouslySelectedAvatar)
                selectedAvatarURL = previouslySelectedAvatar?.url
            }
            toastManager.showToast(message, type: .error)
        }
    }
}

extension AvatarPickerViewModel {
    enum Localized {
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
        static let profileUpdateSuccess = SDKLocalizedString(
            "Profile.Update.Success",
            value: "Profile updated successfully",
            comment: "This confirmation message shows when the user updates fields of their profile."
        )
        static let avatarUpdateFail = SDKLocalizedString(
            "AvatarPickerViewModel.Update.Fail",
            value: "Oops, something didn't quite work out while trying to change your avatar.",
            comment: "This error message shows when the user attempts to pick a different avatar and fails."
        )
        static let profileUpdateFail = SDKLocalizedString(
            "Profile.Update.Fail",
            value: "Oops, something didn't quite work out while trying to update your profile.",
            comment: "This error message shows when the user attempts to update fields of their profile and it fails."
        )
        static let imageTooBigError = SDKLocalizedString(
            "AvatarPicker.Upload.Error.ImageTooBig.Error",
            value: "The provided image exceeds the maximum size: 10MB",
            comment: "Error message to show when the upload fails because the image is too big."
        )
        static let avatarDeletionError = SDKLocalizedString(
            "AvatarPickerViewModel.Delete.Error",
            value: "Oops, there was an error deleting the image.",
            comment: "This error message shows when the user attempts to delete an avatar and fails."
        )
        static let avatarShareFail = SDKLocalizedString(
            "AvatarPickerViewModel.Share.Fail",
            value: "Oops, something didn't quite work out while trying to share your avatar.",
            comment: "This error message shows when the user attempts to share an avatar and fails."
        )
        static let avatarAltTextSuccess = SDKLocalizedString(
            "AvatarPickerViewModel.AltText.Success",
            value: "Image alt text was changed successfully.",
            comment: "This confirmation message shows when the user has updated the alt text."
        )
        static let avatarAltTextError = SDKLocalizedString(
            "AvatarPickerViewModel.AltText.Error",
            value: "Oops, something didn't quite work out while trying to update the alt text.",
            comment: "This error message shows when the user attempts to change the alt text of an avatar and fails."
        )
        static let avatarRatingUpdateSuccess = SDKLocalizedString(
            "AvatarPickerViewModel.RatingUpdate.Success",
            value: "Avatar rating was changed successfully.",
            comment: "This confirmation message shows when the user picks a different avatar rating and the change was applied successfully."
        )
        static let avatarRatingError = SDKLocalizedString(
            "AvatarPickerViewModel.Rating.Error",
            value: "Oops, something didn't quite work out while trying to rate your avatar.",
            comment: "This error message shows when the user attempts to change the rating of an avatar and fails."
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

extension AvatarImageModel {
    init(with avatar: AvatarDetails) {
        id = avatar.imageID
        let avatarGridItemSize = Int(AvatarGridConstants.maxAvatarWidth * UITraitCollection.current.displayScale)
        source = .remote(url: avatar.url(withSize: String(avatarGridItemSize)))
        state = .loaded
        isSelected = avatar.isSelected
        altText = avatar.altText
        rating = avatar.imageRating
    }
}

extension Profile {
    fileprivate func aboutModel() -> AboutInfoModel {
        AboutInfoModel(
            displayName: displayName,
            aboutMe: description,
            pronunciation: pronunciation,
            pronouns: pronouns,
            location: location,
            jobTitle: jobTitle,
            company: company,
            firstName: firstName ?? "",
            lastName: lastName ?? ""
        )
    }
}

extension AboutInfoModel {
    fileprivate func hasEqualFields(than profile: Profile) -> Bool {
        firstName == profile.firstName
            && lastName == profile.lastName
            && displayName == profile.displayName
            && aboutMe == profile.description
            && pronunciation == profile.pronunciation
            && pronouns == profile.pronouns
            && location == profile.location
            && jobTitle == profile.jobTitle
            && company == profile.company
    }
}
