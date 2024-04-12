import SwiftUI

public struct Profile: UIViewRepresentable {
    public typealias UIViewType = ProfileView

    @Binding
    var model: ProfileCardModel?

    var palette: PaletteType = .system

    public init(model: Binding<ProfileCardModel?>) {
        self._model = model
    }

    public func makeUIView(context: Context) -> ProfileView {
        let profileView = ProfileView(frame: .zero, paletteType: palette)
        profileView.setContentHuggingPriority(.required, for: .vertical)
        profileView.rootStackView.setContentHuggingPriority(.required, for: .vertical)

        return profileView
    }

    public func updateUIView(_ profileView: ProfileView, context: Context) {
        if let model {
            profileView.update(with: model)
            profileView.avatarImageView.gravatar.setImage(avatarID: model.avatarIdentifier)
        }
        profileView.paletteType = palette
    }

    public func palette(_ palette: PaletteType) -> Self {
        var copy = self
        copy.palette = palette
        return copy
    }
}
