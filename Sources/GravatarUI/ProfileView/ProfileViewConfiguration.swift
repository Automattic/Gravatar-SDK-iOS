import Gravatar
import UIKit

public struct ProfileViewConfiguration: UIContentConfiguration {
    public var model: ProfileModel?
    public var summaryModel: ProfileSummaryModel?
    public let profileStyle: Style
    var avatarID: AvatarIdentifier? {
        model?.avatarIdentifier ?? summaryModel?.avatarIdentifier
    }

    public var palette: PaletteType
    public var padding: UIEdgeInsets = BaseProfileView.defaultPadding
    public var isLoading: Bool = false
    public var avatarActivityIndicatorType: ActivityIndicatorType = .activity
    public var avatarPlaceholder: UIImage? = nil
    public var avatarRating: Rating? = nil
    public var defaultAvatarOption: DefaultAvatarOption? = nil
    public var avatarSettingOptions: [ImageSettingOption]? = nil

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
    public enum Style: String, CaseIterable {
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

    /// Creates a `ProfileViewConfiguration` that is designed for emails without a Gravatar account. This configuration invites the user to claim their
    /// Gravatar profile.
    /// - Parameters:
    ///   - style: Style of the profile view. See: ``ProfileViewConfiguration.Style``
    ///   - userName: Optional. If not provided, a string that says "Your Name" will be shown.
    ///   - palette: The ``PaletteType`` to use.
    /// - Returns: A new `ProfileViewConfiguration`.
    public static func claimProfile(profileStyle style: Style, userName: String? = nil, palette: PaletteType = .system) -> ProfileViewConfiguration {
        switch style {
        case .standard:
            ProfileViewConfiguration.standard(model: ClaimProfileModel(userName: userName), palette: palette).configureAsClaim()
        case .large:
            ProfileViewConfiguration.large(model: ClaimProfileModel(userName: userName), palette: palette).configureAsClaim()
        case .largeSummary:
            ProfileViewConfiguration.largeSummary(model: ClaimProfileModel(userName: userName), palette: palette).configureAsClaim()
        case .summary:
            ProfileViewConfiguration.summary(model: ClaimProfileModel(userName: userName), palette: palette).configureAsClaim()
        }
    }
}

extension ProfileViewConfiguration {
    private func configureAsClaim() -> ProfileViewConfiguration {
        var copy = self
        copy.profileButtonStyle = .create
        copy.avatarPlaceholder = UIImage(named: "empty-profile-avatar")
        return copy
    }
}
