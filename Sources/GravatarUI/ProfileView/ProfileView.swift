import Gravatar
import UIKit

public class ProfileView: BaseProfileView {
    private lazy var topStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [avatarImageView, basicInfoStackView])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = .DS.Padding.split
        return stack
    }()

    private lazy var bottomStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [accountButtonsStackView, UIView.spacer(), profileButton])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
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

    override public init(frame: CGRect) {
        super.init(frame: frame)
        [topStackView, aboutMeLabel, aboutMePlaceholderLabel, bottomStackView, UIView.spacer()].forEach(rootStackView.addArrangedSubview)
        setRootStackViewSpacing()
    }
    
    private func setRootStackViewSpacing() {
        rootStackView.setCustomSpacing(.DS.Padding.double, after: aboutMeLabel)
    }

    public func update(with model: ProfileModel?) {
        isEmpty = model == nil
        guard let model else { return }
        Configure(aboutMeLabel).asAboutMe().content(model).palette(paletteType)
        Configure(displayNameLabel).asDisplayName().content(model).palette(paletteType).font(.DS.headline)
        Configure(personalInfoLabel).asPersonalInfo().content(model).palette(paletteType)
        Configure(profileButton).asProfileButton().style(.view).alignment(.trailing).palette(paletteType)

        updateAccountButtons(with: model)
    }

    override public func update(with config: ProfileViewConfiguration) {
        super.update(with: config)
        update(with: config.model)
    }
    
    public override func showPlaceholders() {
        super.showPlaceholders()
        basicInfoStackView.spacing = .DS.Padding.single
        rootStackView.setCustomSpacing(.DS.Padding.single, after: aboutMeLabel)
        rootStackView.setCustomSpacing(.DS.Padding.double, after: aboutMePlaceholderLabel)
    }
    
    public override func hidePlaceholders() {
        super.hidePlaceholders()
        basicInfoStackView.spacing = 0
        setRootStackViewSpacing()
    }
}
