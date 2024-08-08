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
    private var currentAvatarResult: Result<String, Error>? {
        didSet {
            selectedAvatarID = currentAvatarResult?.value()
        }
    }

    @Published private(set) var selectedAvatarID: String? {
        didSet {
            updateSelectedAvatarURL()
        }
    }
    @Published var selectedAvatarURL: URL?
    @Published private(set) var avatarsResult: Result<AvatarModelList, Error>? {
        didSet {
            updateSelectedAvatarURL()
        }
    }
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
        self.avatarsResult = .success(.init(models: avatarImageModels))
        if let profileModel {
            self.profileResult = .success(profileModel)
        }
    }

    func selectAvatar(with id: String) {
        guard let email else { return }

        selectedAvatarID = id
        Task {
            defer {
                toggleLoading(of: id)
            }
            do {
                toggleLoading(of: id)
                try await postAvatarSelection(with: id, identifier: .email(email))
            } catch {
                // TODO: Handle error (Toast?)
                // Return to previously selected avatar
                selectedAvatarID = currentAvatarResult?.value()
                print(error)
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

        let service = AvatarService()
        do {
            let avatar = try await service.upload(squareImage, accessToken: authToken)
            await ImageCache.shared.setEntry(.ready(squareImage), for: avatar.url)

            let newModel = AvatarImageModel(id: avatar.id, source: .remote(url: avatar.url))
            add(newModel, replacing: localID)
        } catch {
            // TODO: Proper error handling.
            print(error)
        }
    }

    private func add(_ newAvatarModel: AvatarImageModel, replacing replacingID: String? = nil) {
        if case .success(var avatarImageModels) = avatarsResult {
            if let replacingID {
                avatarImageModels =  avatarImageModels.removingModel(replacingID)
            }
            avatarsResult = .success(avatarImageModels.appending(newAvatarModel))
        }
    }

    private func toggleLoading(of avatarID: String) {
        if case .success(let avatarModels) = avatarsResult {
            avatarsResult = .success(avatarModels.togglingLoading(ofID: avatarID))
        }
    }

    private func updateSelectedAvatarURL() {
        if
            let selectedAvatarID,
            case .success(let list) = avatarsResult,
            let selectedModel = list.model(with: selectedAvatarID)
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
        mutableModels.replaceSubrange(index ... index, with: [model])
        return Self(models: mutableModels)
    }

    func removingModel(_ id: String) -> Self {
        var mutableModels = models
        mutableModels.removeAll { $0.id == id }
        return Self(models: mutableModels)
    }

    func togglingLoading(ofID id: String) -> Self {
        guard let imageModel = model(with: id) else {
            return self
        }
        let toggledModel = imageModel.togglingLoading()
        return updatingModel(imageModel, with: toggledModel)
    }

    func appending(_ newModel: AvatarImageModel) -> Self {
        Self(models: [newModel] + models)
    }
}
