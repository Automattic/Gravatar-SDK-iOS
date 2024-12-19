import SwiftUI
import UIKit

struct AvatarImageModel: Hashable, Identifiable, Sendable {
    enum Source: Hashable {
        case remote(url: String)
        case local(image: UIImage)
    }

    enum State: Equatable, Hashable {
        case loaded
        case loading
        case error(supportsRetry: Bool, errorMessage: String)
    }

    let id: String
    let source: Source
    let isSelected: Bool
    let state: State
    let altText: String
    let rating: AvatarRating

    var url: URL? {
        guard case .remote(let url) = source else {
            return nil
        }
        return URL(string: url)
    }

    var shareURL: URL? {
        guard case .remote(let url) = source else {
            return nil
        }
        return URLComponents(string: url)?.replacingQueryItem(name: "size", value: "max").url
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

    init(id: String, source: Source, state: State, isSelected: Bool, rating: AvatarRating, altText: String) {
        self.id = id
        self.source = source
        self.state = state
        self.isSelected = isSelected
        self.rating = rating
        self.altText = altText
    }

    func updating(_ callback: (inout Builder) -> Void) -> AvatarImageModel {
        var builder = Builder(self)
        callback(&builder)
        return builder.build()
    }
}

extension AvatarImageModel {
    struct Builder {
        var id: String
        var source: Source
        var isSelected: Bool
        var state: State
        var altText: String
        var rating: AvatarRating

        fileprivate init(_ model: AvatarImageModel) {
            self.id = model.id
            self.source = model.source
            self.isSelected = model.isSelected
            self.state = model.state
            self.altText = model.altText
            self.rating = model.rating
        }

        fileprivate func build() -> AvatarImageModel {
            .init(id: id, source: source, state: state, isSelected: isSelected, rating: rating, altText: altText)
        }
    }
}

extension AvatarImageModel {
    /// This is meant to be used in previews and unit tests only.
    static func preview_init(id: String, source: Source, state: State = .loaded, isSelected: Bool = false, rating: AvatarRating = .g) -> Self {
        AvatarImageModel(id: id, source: source, state: state, isSelected: isSelected, rating: rating, altText: "")
    }
}
