import UIKit
import Gravatar

public struct ProfileViewConfiguration: UIContentConfiguration {
    let model: ProfileModel?
    let summaryModel: ProfileSummaryModel?
    let profileStyle: Style
    var avatarID: AvatarIdentifier? {
        model?.avatarIdentifier ?? summaryModel?.avatarIdentifier
    }

    public var palette: PaletteType
    public var padding: UIEdgeInsets

    init(model: ProfileModel?, palette: PaletteType, profileStyle: Style) {
        self.model = model
        self.summaryModel = nil
        self.palette = palette
        self.profileStyle = profileStyle
        self.padding = profileStyle.defaultPadding
    }

    init(model: ProfileSummaryModel?, palette: PaletteType, profileStyle: Style) {
        self.model = nil
        self.summaryModel = model
        self.palette = palette
        self.profileStyle = profileStyle
        self.padding = profileStyle.defaultPadding
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
    public enum Style {
        case standard
        case summary
        // case large
        // case largeSummary
    }
}

extension ProfileViewConfiguration.Style {
    var defaultPadding: UIEdgeInsets {
        switch self {
        case .standard:
            ProfileView.defaultPadding
        case .summary:
            ProfileSummaryView.defaultPadding
        }
    }
}

extension ProfileViewConfiguration {
    public static func standard(model: ProfileModel? = nil, palette: PaletteType = .system) -> ProfileViewConfiguration {
        self.init(model: model, palette: palette, profileStyle: .standard)
    }

    public static func summary(model: ProfileSummaryModel? = nil, palette: PaletteType = .system) -> ProfileViewConfiguration {
        self.init(model: model, palette: palette, profileStyle: .summary)
    }
}
