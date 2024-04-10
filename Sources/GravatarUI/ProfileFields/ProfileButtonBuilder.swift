import UIKit

public enum ProfileButtonStyle {
    case view
}

extension ProfileButtonStyle {
    var localizedTitle: String {
        switch self {
        case .view:
            NSLocalizedString("View profile", comment: "Title for edit button in Gravatar profile view")
        }
    }
}

public struct ProfileButtonBuilder {
    let button: UIButton
    init(button: UIButton) {
        self.button = button
        button.configuration = .profileButton()
        button.contentHorizontalAlignment = .leading
    }

    @discardableResult
    public func style(_ style: ProfileButtonStyle) -> ProfileButtonBuilder {
        var config = button.configuration
        config?.attributedTitle = AttributedString(
            style.localizedTitle,
            attributes: AttributeContainer([NSAttributedString.Key.font: UIFont.DS.Body.xSmall])
        )
        button.configuration = config
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
    public func alignment(_ alignment: UIControl.ContentHorizontalAlignment) -> ProfileButtonBuilder {
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
