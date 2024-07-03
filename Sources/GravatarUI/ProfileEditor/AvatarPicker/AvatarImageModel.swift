import UIKit

struct AvatarImageModel: Hashable, Identifiable {
    enum State: Hashable {
        case remote(url: String, isLoading: Bool)
        case local(image: UIImage)
    }

    let id: String
    let state: State

    var url: URL? {
        guard case .remote(let url, _) = state else {
            return nil
        }
        return URL(string: url)
    }

    init(id: String, state: State) {
        self.id = id
        self.state = state
    }

    func togglingLoading() -> AvatarImageModel {
        if case .remote(let url, let isLoading) = state {
            return AvatarImageModel(id: id, state: .remote(url: url, isLoading: !isLoading))
        } else {
            return self
        }
    }
}

extension ProfileIdentity {
    var selectedAvatarModel: AvatarImageModel {
        AvatarImageModel(id: imageId, state: .remote(url: imageUrl, isLoading: false))
    }
}
