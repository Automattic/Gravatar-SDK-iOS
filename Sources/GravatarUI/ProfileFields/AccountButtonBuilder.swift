import Gravatar
import UIKit

@MainActor
public struct AccountButtonBuilder {
    static let fallbackIcon: UIImage? = UIImage(localName: "link")
    let button: UIButton
    init(button: UIButton) {
        self.button = button
    }

    @discardableResult
    public func content(_ model: AccountModel) -> AccountButtonBuilder {
        var config = UIButton.Configuration.accountButton()
        config.image = image(with: model)
        button.configuration = config
        button.setContentHuggingPriority(.required, for: .horizontal)
        return self
    }

    private func image(with model: AccountModel) -> UIImage? {
        UIImage(localName: model.shortname) ?? Self.fallbackIcon
    }

    @discardableResult
    public func palette(_ paletteType: PaletteType) -> AccountButtonBuilder {
        var config = button.configuration
        config?.baseForegroundColor = paletteType.palette.foreground.primary
        config?.imagePadding = 0
        button.configuration = config
        return self
    }
}

extension UIImage {
    convenience init?(localName: String) {
        self.init(named: localName, in: Bundle.module, with: nil)
    }
}

extension UIButton.Configuration {
    fileprivate static func accountButton() -> UIButton.Configuration {
        var config = UIButton.Configuration.borderless()
        var insets = config.contentInsets
        insets.leading = 0
        insets.trailing = 0
        config.contentInsets = insets
        return config
    }
}
