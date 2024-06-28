import Gravatar
import UIKit

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
/// See: ``ProfileView``, ``ProfileSummaryView``, ``LargeProfileView``, ``LargeProfileSummaryView``.
/// After creating a configuration, you can modify any of the available fields to properly configure the profile view.
///
@MainActor
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
    /// A customization block on the PaletteType. Set this if you need to partially alter the current palette.
    public var paletteCustomizer: PaletteCustomizer?
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
    /// All the different style designs for the profile view.
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
    /// A configuration that specifies the behavior and loading options for the profile avatar.
    public struct AvatarConfiguration {
        /// The activity indicator used on the image view while the avatar is loading. See ``ActivityIndicatorType`` for more info.
        public var activityIndicatorType: ActivityIndicatorType = .activity
        /// An image to be displayed while an avatar image has not been set.
        public var placeholder: UIImage? = nil
        /// The maximum rating of the avatar for it to be displayed. See ``Rating`` for more info.
        public var rating: Rating? = nil
        /// The avatar style to be displayed when no avatar has been found
        /// See ``DefaultAvatarOption`` for more info.
        public var defaultAvatarOption: DefaultAvatarOption? = nil
        /// Options for fetchingg the avatar image. See ``ImageSettingOption`` for more info.
        public var settingOptions: [ImageSettingOption]? = nil
        /// A closure that calculates the corner radius of avatar based on its length.
        /// By default, the avatar is circle shaped.
        public var cornerRadiusCalculator: AvatarCornerRadiusCalculator = AvatarConstants.cornerRadiusCalculator
        /// The border width of the avatar.
        public var borderWidth: CGFloat = 1
        /// The border color of the avatar. If not set, the border color from the palette is used. See ``Palette`` . ``Palette/avatar`` .
        /// ``AvatarColors/border``.
        public var borderColor: UIColor? = nil
        /// Length of the avatar. If not set, a suitable length is chosen according to the ``ProfileViewConfiguration/Style``.
        public var avatarLength: CGFloat? = nil
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
    ///   - style: Style of the profile view. See: ``Style``
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
        copy.paletteCustomizer = { paletteType in
            switch paletteType {
            case .custom:
                paletteType
            case .light:
                .custom {
                    paletteType.palette.withReplacing(
                        avatarColors: { $0.withReplacing(background: .white, tint: .porpoiseGray) }
                    )
                }
            case .dark:
                .custom {
                    paletteType.palette.withReplacing(
                        avatarColors: { $0.withReplacing(background: .gravatarBlack, tint: .bovineGray) }
                    )
                }
            case .system:
                .custom {
                    paletteType.palette.withReplacing(
                        avatarColors: {
                            $0.withReplacing(
                                background: UIColor(light: .white, dark: .gravatarBlack),
                                tint: UIColor(light: .porpoiseGray, dark: .bovineGray)
                            )
                        }
                    )
                }
            }
        }
        var avatarConfig = AvatarConfiguration()
        avatarConfig.placeholder = UIImage(named: "empty-profile-avatar")
        copy.avatarConfiguration = avatarConfig
        return copy
    }
}
