import Gravatar
import UIKit

@MainActor
/// A configuration that specifies the appearance and behavior of a ProfileView and its contents.
///
/// You can use a configuration instance to configure a ProfileView, or to create one using `makeContentView()` method.
///
/// To configure a specific ProfileView style, use the static method provided to create a new configuration with the desired style:
/// ```swift
/// ProfileViewConfiguration.standard()     // ProfileView
/// ProfileViewConfiguration.summary()      // ProfileSummaryView
/// ProfileViewConfiguration.large()        // LargeProfileView
/// ProfileViewConfiguration.largeSummary() // LargeProfileSummaryView
/// ```
/// After creating a configuration, you can modify any of the available fields to properly configure the profile view.
///
public struct ProfileViewConfiguration: UIContentConfiguration {
    /// The model used to populate the view's content.
    public var model: ProfileModel?
    /// The model used to populate summary-styled profile views.
    public var summaryModel: ProfileSummaryModel?
    /// The style for the profile view.
    public let profileStyle: Style
    /// The identifier for the avatar image to be loaded in the profile view.
    var avatarID: AvatarIdentifier? {
        model?.avatarIdentifier ?? summaryModel?.avatarIdentifier
    }
    /// The palette to be used to style the view.
    public var palette: PaletteType
    /// Creates a padding space around the content of the profile view.
    /// To remove all pading, set this to zero.
    public var padding: UIEdgeInsets = BaseProfileView.defaultPadding
    /// Wether the state of the view is `loading`.
    /// Set this property to `true` when the profile information is being retreived and not yet set to the profile view.
    public var isLoading: Bool = false
    /// A configuration to control the loading and behavior of the profile avatar.
    public var avatarConfiguration = AvatarConfiguration()
    /// Style of the button on the action button on the profile view.
    public var profileButtonStyle: ProfileButtonStyle = .view
    /// The delegate will receive events from various interations of the user on the profile view.
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

    public nonisolated func updated(for state: UIConfigurationState) -> ProfileViewConfiguration {
        self
    }
}

extension ProfileViewConfiguration {
    /// All the different styel designs for the profile view.
    public enum Style: String, CaseIterable {
        /// The configuration will create a ``ProfileView`` instance.
        case standard
        /// The configuration will create a ``ProfileSummaryView`` instance.
        case summary
        /// The configuration will create a ``LargeProfileView`` instance.
        case large
        /// The configuration will create a ``LargeProfileSummaryView`` instance.
        case largeSummary
    }
}

extension ProfileViewConfiguration {
    public struct AvatarConfiguration {
        /// The activity indicator used on the image view while the avatar is loading.
        public var activityIndicatorType: ActivityIndicatorType = .activity
        /// An image to be displayed while an avatar image has not been set.
        public var placeholder: UIImage? = nil
        /// The maximum rating of the avatar for it to be displayed. See ``Gravatar.Rating`` for more info.
        public var rating: Rating? = nil
        /// The avatar style to be displayed when no avatar has been found
        /// See ``Gravatar.DefaultAvatarOption`` for more info.
        public var defaultAvatarOption: DefaultAvatarOption? = nil
        /// Options for fetchingg the avatar image. See ``Gravatar.ImageSettingOption`` for more info.
        public var settingOptions: [ImageSettingOption]? = nil
    }
}

extension ProfileViewConfiguration {
    /// Creates a configuration set with the `standard` style.
    /// - Parameters:
    ///   - model: The model to be used to populate the profile view content.
    ///   - palette: The palette to apply to the view.
    /// - Returns: A configuration set with the standard style.
    public static func standard(model: ProfileModel? = nil, palette: PaletteType = .system) -> ProfileViewConfiguration {
        self.init(model: model, palette: palette, profileStyle: .standard)
    }
    /// Creates a configuration set with the `summary` style.
    /// - Parameters:
    ///   - model: The model to be used to populate the profile view content.
    ///   - palette: The palette to apply to the view.
    /// - Returns: A configuration set with the summary style.
    public static func summary(model: ProfileSummaryModel? = nil, palette: PaletteType = .system) -> ProfileViewConfiguration {
        self.init(model: model, palette: palette, profileStyle: .summary)
    }
    /// Creates a configuration set with the `large` style.
    /// - Parameters:
    ///   - model: The model to be used to populate the profile view content.
    ///   - palette: The palette to apply to the view.
    /// - Returns: A configuration set with the large style.
    public static func large(model: ProfileModel? = nil, palette: PaletteType = .system) -> ProfileViewConfiguration {
        self.init(model: model, palette: palette, profileStyle: .large)
    }
    /// Creates a configuration set with the `largeSummary` style.
    /// - Parameters:
    ///   - model: The model to be used to populate the profile view content.
    ///   - palette: The palette to apply to the view.
    /// - Returns: A configuration set with the largeSummary style.
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
        var avatarConfig = AvatarConfiguration()
        avatarConfig.placeholder = UIImage(named: "empty-profile-avatar")
        copy.avatarConfiguration = avatarConfig
        return copy
    }
}
