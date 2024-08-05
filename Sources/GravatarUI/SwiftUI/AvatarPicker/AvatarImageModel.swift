import UIKit

struct AvatarImageModel: Hashable, Identifiable {
    enum Source: Hashable {
        case remote(url: String)
        case local(image: UIImage)
    }

    let id: String
    let isLoading: Bool
    let source: Source

    var url: URL? {
        guard case .remote(let url) = source else {
            return nil
        }
        return URL(string: url)
    }

    var localImage: UIImage? {
        guard case .local(let image) = source else {
            return nil
        }
        return image
    }

    init(id: String, source: Source, isLoading: Bool = false) {
        self.id = id
        self.source = source
        self.isLoading = isLoading
    }

    func togglingLoading() -> AvatarImageModel {
        AvatarImageModel(id: id, source: source, isLoading: !isLoading)
    }
}
