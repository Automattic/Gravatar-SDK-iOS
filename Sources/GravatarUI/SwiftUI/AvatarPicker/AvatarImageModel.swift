import SwiftUI
import UIKit

struct AvatarImageModel: Hashable, Identifiable, Sendable {
    enum Source: Hashable {
        case remote(url: String)
        case local(image: UIImage)
    }

    enum State {
        case loaded
        case loading
        case retry
        case error
    }

    let id: String
    let source: Source
    let isSelected: Bool
    let state: State

    var url: URL? {
        guard case .remote(let url) = source else {
            return nil
        }
        return URL(string: url)
    }

    var localImage: Image? {
        guard case .local(let image) = source else {
            return nil
        }
        return Image(uiImage: image)
    }

    var localUIImage: UIImage? {
        guard case .local(let image) = source else {
            return nil
        }
        return image
    }

    init(id: String, source: Source, state: State = .loaded, isSelected: Bool = false) {
        self.id = id
        self.source = source
        self.state = state
        self.isSelected = isSelected
    }

    func settingStatus(to newStatus: State) -> AvatarImageModel {
        AvatarImageModel(id: id, source: source, state: newStatus)
    }
}
