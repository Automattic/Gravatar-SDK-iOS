import Foundation

/// Describes and manages a grid of avatars.
class AvatarGridModel: ObservableObject {
    @Published private(set) var avatars: [AvatarImageModel]
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

    func replaceModel(withID id: String, with model: AvatarImageModel) {
        guard let index = index(of: id) else { return }
        avatars[index] = model
    }

    func removeModel(_ id: String) {
        avatars.removeAll { $0.id == id }
    }

    func setState(to state: AvatarImageModel.State, onAvatarWithID id: String) {
        guard let imageModel = model(with: id) else { return }
        let toggledModel = imageModel.updating { $0.state = state }
        replaceModel(withID: id, with: toggledModel)
    }

    func insert(_ newModel: AvatarImageModel, at index: Int) {
        avatars.insert(newModel, at: index)
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
        if let selectedModel = model(with: selectedID) {
            selectedAvatar = selectedModel
        }
    }

    func setAvatars(_ avatars: [AvatarImageModel]) {
        self.avatars = avatars
        if let selected = avatars.first(where: { $0.isSelected }) {
            selectAvatar(selected)
        }
    }

    func deleteModel(_ id: String) -> Int? {
        guard let index = avatars.firstIndex(where: { $0.id == id }) else { return nil }
        avatars.removeAll { $0.id == id }
        if selectedAvatar?.id == id {
            selectedAvatar = nil
        }
        return index
    }
}
