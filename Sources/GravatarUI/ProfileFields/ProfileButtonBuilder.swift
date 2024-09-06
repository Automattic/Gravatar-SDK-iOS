import UIKit

/// Styles for the profile view action button.
///
public enum ProfileButtonStyle {
    /// Style which provides a link to display the profile.
    case view
    /// Style which provides a link to edit the profile.
    /// >  Use this option only when the profile is owned by your app's authenticated user.
    case edit
    /// Style which provides a link to crerate a new account.
    /// > This style is automatically set when the view is configured as `claimProfile`.
    case create
}

extension ProfileButtonStyle {
    var localizedTitle: String {
        switch self {
        case .view:
            NSLocalizedString(
                "ProfileButton.title.view",
                bundle: .module,
                value: "View profile",
                comment: "Title for a button that allows you to view your Gravatar profile"
            )
        case .edit:
            NSLocalizedString(
                "ProfileButton.title.edit",
                bundle: .module,
                value: "Edit profile",
                comment: "Title for a button that allows you to edit your Gravatar profile"
            )
        case .create:
            NSLocalizedString(
                "ProfileButton.title.create",
                bundle: .module,
                value: "Claim profile",
                comment: "Title for a button that allows you to claim a new Gravatar profile"
            )
        }
    }
}

@MainActor
public struct ProfileButtonBuilder {
    let button: UIButton
    init(button: UIButton) {
        self.button = button
    }

    @discardableResult
    public func style(_ style: ProfileButtonStyle) -> ProfileButtonBuilder {
        var config = UIButton.Configuration.profileButton()
        config.attributedTitle = AttributedString(
            style.localizedTitle,
            attributes: AttributeContainer([NSAttributedString.Key.font: UIFont.DS.Body.xSmall])
        )
        button.configuration = config
        button.contentHorizontalAlignment = .leading
        return self
    }

    @discardableResult
    public func palette(_ paletteType: PaletteType) -> ProfileButtonBuilder {
        var config = button.configuration
        config?.baseForegroundColor = paletteType.palette.foreground.primary
        button.configuration = config
        return self
    }

    @discardableResult
    func alignment(_ alignment: UIControl.ContentHorizontalAlignment) -> ProfileButtonBuilder {
        button.contentHorizontalAlignment = alignment
        return self
    }
}

extension UIButton.Configuration {
    fileprivate static func profileButton() -> UIButton.Configuration {
        var config = UIButton.Configuration.borderless()
        var insets = config.contentInsets
        insets.leading = 0
        insets.trailing = 0
        config.contentInsets = insets

        config.image = UIImage(systemName: "arrow.forward")
        config.imagePlacement = .trailing
        config.imagePadding = .DS.Padding.half
        config.preferredSymbolConfigurationForImage = .some(.init(pointSize: 14, weight: .bold, scale: .small))

        return config
    }
}
