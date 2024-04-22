import Gravatar
import UIKit

public struct ProfileViewConfiguration: UIContentConfiguration {
    let model: ProfileModel?
    let summaryModel: ProfileSummaryModel?
    let profileStyle: Style
    var avatarID: AvatarIdentifier? {
        model?.avatarIdentifier ?? summaryModel?.avatarIdentifier
    }

    public var palette: PaletteType
    public var padding: UIEdgeInsets = BaseProfileView.defaultPadding
    public var profileButtonStyle: ProfileButtonStyle = .view
    public weak var delegate: ProfileViewDelegate?

    init(model: ProfileModel?, palette: PaletteType, profileStyle: Style) {
        self.model = model
        self.summaryModel = nil
        self.palette = palette
        self.profileStyle = profileStyle
    }

    init(model: ProfileSummaryModel?, palette: PaletteType, profileStyle: Style) {
        self.model = nil
        self.summaryModel = model
        self.palette = palette
        self.profileStyle = profileStyle
    }

    public func makeContentView() -> UIView & UIContentView {
        let view: BaseProfileView = switch profileStyle {
        case .standard:
            ProfileView(frame: .zero)
        case .summary:
            ProfileSummaryView(frame: .zero)
        case .large:
            LargeProfileView(frame: .zero)
        case .largeSummary:
            LargeProfileSummaryView(frame: .zero)
        }
        view.configuration = self
        view.delegate = self.delegate
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
        case large
        case largeSummary
    }
}

extension ProfileViewConfiguration {
    public static func standard(model: ProfileModel? = nil, palette: PaletteType = .system) -> ProfileViewConfiguration {
        self.init(model: model, palette: palette, profileStyle: .standard)
    }

    public static func summary(model: ProfileSummaryModel? = nil, palette: PaletteType = .system) -> ProfileViewConfiguration {
        self.init(model: model, palette: palette, profileStyle: .summary)
    }

    public static func large(model: ProfileModel? = nil, palette: PaletteType = .system) -> ProfileViewConfiguration {
        self.init(model: model, palette: palette, profileStyle: .large)
    }

    public static func largeSummary(model: ProfileSummaryModel? = nil, palette: PaletteType = .system) -> ProfileViewConfiguration {
        self.init(model: model, palette: palette, profileStyle: .largeSummary)
    }
}
