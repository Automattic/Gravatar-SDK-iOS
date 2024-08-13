import Foundation

/// Describes and manages a grid of avatars.
class GridModel: ObservableObject {
    @Published var avatars: [AvatarImageModel]
    @Published var selectedAvatar: AvatarImageModel?

    var isEmpty: Bool {
        avatars.isEmpty
    }

    init(avatars: [AvatarImageModel], selectedAvatar: AvatarImageModel? = nil) {
        self.avatars = avatars
        self.selectedAvatar = selectedAvatar
    }

    func model(with id: String) -> AvatarImageModel? {
        avatars.first { $0.id == id }
    }

    func index(of id: String) -> Int? {
        avatars.firstIndex { $0.id == id }
    }

    func updateModel(_ currentModel: AvatarImageModel, with model: AvatarImageModel) {
        guard let index = index(of: currentModel.id) else { return }
        avatars[index] = model
    }

    func removeModel(_ id: String) {
        avatars.removeAll { $0.id == id }
    }

    func setLoading(to isLoading: Bool, onAvatarWithID id: String) {
        guard let imageModel = model(with: id) else { return }
        let toggledModel = imageModel.settingLoading(to: isLoading)
        updateModel(imageModel, with: toggledModel)
    }

    func append(_ newModel: AvatarImageModel) {
        avatars.insert(newModel, at: 0)
    }

    func selectAvatar(_ selected: AvatarImageModel?) {
        selectedAvatar = selected
    }

    func selectAvatar(withID selectedID: String?) {
        guard let selectedID else {
            selectedAvatar = nil
            return
        }
        selectedAvatar = model(with: selectedID)
    }
}
