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

    private var avatarSelectionTask: Task<Void, Never>?
    private var authToken: String?
    private var currentAvatarResult: Result<String, Error>? {
        didSet {
            if let selectedAvatarID = currentAvatarResult?.value() {
                self.selectedAvatarID = selectedAvatarID
                updateSelectedAvatarURL()
            }
        }
    }

    @Published private(set) var selectedAvatarID: String?
    @Published var selectedAvatarURL: URL?
    @Published private(set) var avatarsResult: Result<AvatarModelList, Error>?

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
    @ObservedObject var toastManager: ToastManager

    init(email: Email, authToken: String) {
        self.email = email
        avatarIdentifier = .email(email)
        self.authToken = authToken
        self.toastManager = ToastManager()
    }

    /// Internal init for previewing purposes. Do not make this public.
    init(avatarImageModels: [AvatarImageModel], selectedImageID: String? = nil, profileModel: ProfileSummaryModel? = nil) {
        if let selectedImageID {
            self.currentAvatarResult = .success(selectedImageID)
        } else {
            self.currentAvatarResult = nil
        }
        self.avatarsResult = .success(.init(models: avatarImageModels))
        if let profileModel {
            self.profileResult = .success(profileModel)
        }
        self.toastManager = ToastManager()
    }

    func selectAvatar(with id: String) {
        guard
            let email,
            selectedAvatarID != id
        else { return }

        avatarSelectionTask?.cancel()

        avatarSelectionTask = Task {
            defer {
                setLoading(to: false, onAvatarWithID: id)
            }
            selectedAvatarID = id
            do {
                setLoading(to: true, onAvatarWithID: id)
                try await postAvatarSelection(with: id, identifier: .email(email))
                toastManager.showToast("Avatar updated! It may take a few minutes to appear everywhere.", type: .info)
            } catch APIError.responseError(let reason) where reason.cancelled {
                // NoOp.
            } catch {
                // TODO: Handle error (Toast?)
                // Return to previously selected avatar
                selectedAvatarID = currentAvatarResult?.value()
            }
        }
    }

    func postAvatarSelection(with avatarID: String, identifier: ProfileIdentifier) async throws {
        guard let authToken else { return }
        let response = try await profileService.selectAvatar(token: authToken, profileID: identifier, avatarID: avatarID)
        currentAvatarResult = .success(response.imageId)
    }

    func fetchAvatars() async {
        guard let authToken else { return }

        do {
            isAvatarsLoading = true
            let images = try await profileService.fetchAvatars(with: authToken)
            let avatarModels = images.map { AvatarImageModel(id: $0.id, source: .remote(url: $0.url)) }

            avatarsResult = .success(.init(models: avatarModels))
            updateSelectedAvatarURL()
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

    func upload(_ image: UIImage) async {
        let squareImage = image.squared()
        await performUpload(of: squareImage)
    }

    private func performUpload(of squareImage: UIImage) async {
        guard let authToken else { return }

        let localID = UUID().uuidString

        let localImageModel = AvatarImageModel(id: localID, source: .local(image: squareImage), isLoading: true)
        add(localImageModel)

        await doUpload(image: squareImage, localID: localID, accessToken: authToken)
    }

    func retryUpload(of localID: String) async {
        guard let authToken,
              let avatarImageModels = avatarsResult?.value(),
              let model = avatarImageModels.models.first(where: { $0.id == localID }),
              let localImage = model.localUIImage
        else {
            return
        }

        let newModel = AvatarImageModel(id: localID, source: .local(image: localImage), isLoading: true, uploadHasFailed: false)
        add(newModel, replacing: localID)

        await doUpload(image: localImage, localID: localID, accessToken: authToken)
    }

    private func doUpload(image: UIImage, localID: String, accessToken: String) async {
        let service = AvatarService()
        do {
            let avatar = try await service.upload(image, accessToken: accessToken)
            await ImageCache.shared.setEntry(.ready(image), for: avatar.url)

            let newModel = AvatarImageModel(id: avatar.id, source: .remote(url: avatar.url))
            add(newModel, replacing: localID)
        } catch {
            let newModel = AvatarImageModel(id: localID, source: .local(image: image), isLoading: false, uploadHasFailed: true)
            add(newModel, replacing: localID)
            toastManager.showToast("Ooops, there was an error uploading the image.", type: .error)
            // TODO: Proper error handling.
            // print(error)
        }
    }

    private func add(_ newAvatarModel: AvatarImageModel, replacing replacingID: String? = nil) {
        if var avatarImageModels = avatarsResult?.value() {
            if let replacingID {
                avatarImageModels = avatarImageModels.removingModel(replacingID)
            }
            avatarsResult = .success(avatarImageModels.appending(newAvatarModel))
        }
    }

    private func setLoading(to isLoading: Bool, onAvatarWithID avatarID: String) {
        if let avatarModels = avatarsResult?.value() {
            avatarsResult = .success(avatarModels.settingLoading(to: isLoading, onAvatarWithID: avatarID))
        }
    }

    private func updateSelectedAvatarURL() {
        if
            let selectedAvatarID,
            let avatarList = avatarsResult?.value(),
            let selectedModel = avatarList.model(with: selectedAvatarID)
        {
            selectedAvatarURL = selectedModel.url
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

extension UIImage {
    private func squared() -> UIImage {
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

/// Struct that manages the models array.
struct AvatarModelList {
    let models: [AvatarImageModel]

    func model(with id: String) -> AvatarImageModel? {
        models.first { $0.id == id }
    }

    func index(of id: String) -> Int? {
        models.firstIndex { $0.id == id }
    }

    func updatingModel(withID id: String, with newModel: AvatarImageModel) -> Self {
        guard let currentModel = model(with: id) else { return self }
        return updatingModel(currentModel, with: newModel)
    }

    func updatingModel(_ currentModel: AvatarImageModel, with model: AvatarImageModel) -> Self {
        guard let index = index(of: currentModel.id) else { return self }

        var mutableModels = models
        mutableModels[index] = model
        return Self(models: mutableModels)
    }

    func removingModel(_ id: String) -> Self {
        var mutableModels = models
        mutableModels.removeAll { $0.id == id }
        return Self(models: mutableModels)
    }

    func settingLoading(to isLoading: Bool, onAvatarWithID id: String) -> Self {
        guard let imageModel = model(with: id) else {
            return self
        }
        let toggledModel = imageModel.settingLoading(to: isLoading)
        return updatingModel(imageModel, with: toggledModel)
    }

    func settingUploadFailed(to uploadHasFailed: Bool, onAvatarWithID id: String) -> Self {
        guard let imageModel = model(with: id) else {
            return self
        }
        let newModel = imageModel.settingUploadHasFailed(to: uploadHasFailed)
        return updatingModel(imageModel, with: newModel)
    }

    func appending(_ newModel: AvatarImageModel) -> Self {
        Self(models: [newModel] + models)
    }
}
