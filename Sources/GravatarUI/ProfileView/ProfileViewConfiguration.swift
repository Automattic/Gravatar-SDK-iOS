import UIKit

public struct ProfileViewConfiguration: UIContentConfiguration {
    let model: ProfileCardModel?
    let summaryModel: ProfileCardSummaryModel?

    let palette: PaletteType
    let profileStyle: ProfileViewStyle

    init(model: ProfileCardModel?, palette: PaletteType, profileStyle: ProfileViewStyle) {
        self.model = model
        self.summaryModel = nil
        self.palette = palette
        self.profileStyle = profileStyle
    }

    init(model: ProfileCardSummaryModel?, palette: PaletteType, profileStyle: ProfileViewStyle) {
        self.model = nil
        self.summaryModel = model
        self.palette = palette
        self.profileStyle = profileStyle
    }

    public func makeContentView() -> UIView & UIContentView {
        let view: UIView & UIContentView
        switch profileStyle {
        case .standard:
            view = ProfileView(frame: .zero, paletteType: palette)
        case .summary:
            view = ProfileSummaryView(frame: .zero, paletteType: palette)
        }
        view.configuration = self
        return view
    }

    public func updated(for state: UIConfigurationState) -> ProfileViewConfiguration {
        self
    }
}

extension ProfileViewConfiguration {
    public enum ProfileViewStyle {
        case standard
        case summary
        // case large
        // case largeSummary
    }
}

extension ProfileViewConfiguration {
    public static func standard(model: ProfileCardModel? = nil, palette: PaletteType = .system) -> ProfileViewConfiguration {
        self.init(model: model, palette: palette, profileStyle: .standard)
    }

    public static func summary(model: ProfileCardSummaryModel? = nil, palette: PaletteType = .system) -> ProfileViewConfiguration {
        self.init(model: model, palette: palette, profileStyle: .summary)
    }
}

extension ProfileView: UIContentView {
    public var configuration: UIContentConfiguration {
        get {
            ProfileViewConfiguration.standard(model: model, palette: paletteType)
        }
        set(newValue) {
            guard let config = newValue as? ProfileViewConfiguration else { return }
            if let model = config.model {
                update(with: model)
                avatarImageView.gravatar.setImage(avatarID: model.avatarIdentifier)
            }
            paletteType = config.palette
        }
    }
}

extension ProfileSummaryView: UIContentView {
    public var configuration: UIContentConfiguration {
        get {
            ProfileViewConfiguration.summary(model: model, palette: paletteType)
        }
        set(newValue) {
            guard let config = newValue as? ProfileViewConfiguration else { return }
            if let model = config.summaryModel {
                update(with: model)
                avatarImageView.gravatar.setImage(avatarID: model.avatarIdentifier)
            }
            paletteType = config.palette
        }
    }
}
