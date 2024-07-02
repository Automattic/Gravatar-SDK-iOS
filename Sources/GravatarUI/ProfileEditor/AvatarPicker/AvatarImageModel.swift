import UIKit

struct AvatarImageModel: Hashable, Identifiable {
    enum State: Hashable {
        case remote(url: String)
        case local(image: UIImage)
    }

    let id: String
    let state: State

    var url: URL? {
        guard case .remote(let url) = state else {
            return nil
        }
        return URL(string: url)
    }

    init(id: String, state: State) {
        self.id = id
        self.state = state
    }
}
