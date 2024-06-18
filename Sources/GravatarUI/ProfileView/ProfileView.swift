import Gravatar
import UIKit

/// ![](profileView.view)
/// A profile view with standard layout
public class ProfileView: BaseProfileView {
    private lazy var topStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [avatarView, basicInfoStackView])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = .DS.Padding.split
        return stack
    }()

    private lazy var bottomStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [accountButtonsStackView, .spacer(), profileButton])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.distribution = .equalCentering
        stack.spacing = .DS.Padding.split
        stack.alignment = .center
        return stack
    }()

    private lazy var basicInfoStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [displayNameLabel, personalInfoLabel])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.alignment = .leading
        stack.distribution = .equalCentering
        return stack
    }()

    override public func arrangeSubviews() {
        [topStackView, aboutMeLabel, aboutMePlaceholderLabel, bottomStackView].forEach(rootStackView.addArrangedSubview)
        setRootStackViewSpacing()
    }

    private func setRootStackViewSpacing() {
        basicInfoStackView.spacing = 0
        rootStackView.setCustomSpacing(.DS.Padding.double, after: aboutMeLabel)
        rootStackView.setCustomSpacing(0, after: bottomStackView)
    }

    public func update(with model: ProfileModel?) {
        self.model = model
        guard let model else { return }
        Configure(aboutMeLabel).asAboutMe().content(model).palette(paletteType)
        Configure(displayNameLabel).asDisplayName().content(model).palette(paletteType).font(.DS.headline)
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
        basicInfoStackView.spacing = .DS.Padding.single
        rootStackView.setCustomSpacing(.DS.Padding.single, after: aboutMeLabel)
        rootStackView.setCustomSpacing(.DS.Padding.double, after: aboutMePlaceholderLabel)
    }

    override public func hidePlaceholders() {
        super.hidePlaceholders()
        setRootStackViewSpacing()
    }
}
