import Gravatar
import UIKit

/// ![](largeProfileView.view)
/// A  profile view with large avatar image.
public class LargeProfileView: BaseProfileView {
    private enum Constants {
        static let avatarLength: CGFloat = 132.0
        static let displayNamePlaceholderHeight: CGFloat = 32
    }

    override public class var avatarLength: CGFloat {
        Constants.avatarLength
    }

    private lazy var topStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [avatarView, .spacer()])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        return stack
    }()

    private lazy var bottomStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [accountButtonsStackView, .spacer(), profileButton])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.alignment = .center
        stack.distribution = .equalCentering
        stack.spacing = .DS.Padding.split
        return stack
    }()

    override public func arrangeSubviews() {
        [topStackView, displayNameLabel, personalInfoLabel, aboutMeLabel, aboutMePlaceholderLabel, bottomStackView]
            .forEach(rootStackView.addArrangedSubview)
        setRootStackViewSpacing()
    }

    private func setRootStackViewSpacing() {
        rootStackView.setCustomSpacing(.DS.Padding.double, after: avatarView)
        rootStackView.setCustomSpacing(0, after: displayNameLabel)
        rootStackView.setCustomSpacing(.DS.Padding.double, after: aboutMeLabel)
        rootStackView.setCustomSpacing(0, after: aboutMePlaceholderLabel)
        rootStackView.setCustomSpacing(.DS.Padding.single, after: personalInfoLabel)
        rootStackView.setCustomSpacing(0, after: bottomStackView)
    }

    public func update(with model: ProfileModel?) {
        self.model = model
        guard let model else { return }
        Configure(aboutMeLabel).asAboutMe().content(model).palette(paletteType)
        Configure(displayNameLabel).asDisplayName().content(model).palette(paletteType)
        Configure(personalInfoLabel).asPersonalInfo().content(model).palette(paletteType)
        Configure(profileButton).asProfileButton().style(profileButtonStyle).alignment(.trailing).palette(paletteType)
        updateAccountButtons(with: model)
    }

    override public func update(with config: ProfileViewConfiguration) {
        update(with: config.model)
        super.update(with: config)
    }

    override public func showPlaceholders() {
        super.showPlaceholders()
        rootStackView.setCustomSpacing(.DS.Padding.single, after: displayNameLabel)
        rootStackView.setCustomSpacing(.DS.Padding.double, after: personalInfoLabel)
        rootStackView.setCustomSpacing(.DS.Padding.single, after: aboutMeLabel)
        rootStackView.setCustomSpacing(.DS.Padding.double, after: aboutMePlaceholderLabel)
    }

    override public func hidePlaceholders() {
        super.hidePlaceholders()
        setRootStackViewSpacing()
    }

    override public var displayNamePlaceholderHeight: CGFloat {
        Constants.displayNamePlaceholderHeight
    }
}
