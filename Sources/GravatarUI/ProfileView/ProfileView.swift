import Gravatar
import UIKit

public class ProfileView: BaseProfileView {
    private lazy var topStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [avatarImageView, basicInfoStackView])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.spacing = .DS.Padding.split
        return stack
    }()

    private lazy var bottomStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [accountButtonsStackView, profileButton])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.distribution = .fillProportionally
        stack.spacing = .DS.Padding.split
        return stack
    }()

    private lazy var basicInfoStackView: UIStackView = {
        let spacer = UIView()
        spacer.translatesAutoresizingMaskIntoConstraints = false
        spacer.setContentHuggingPriority(.defaultLow, for: .vertical)
        let stack = UIStackView(arrangedSubviews: [displayNameLabel, personalInfoLabel, spacer])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.alignment = .leading
        stack.distribution = .equalCentering
        return stack
    }()

    override public init(frame: CGRect) {
        super.init(frame: frame)
        [topStackView, aboutMeLabel, bottomStackView].forEach(rootStackView.addArrangedSubview)
        rootStackView.setCustomSpacing(.DS.Padding.double, after: aboutMeLabel)
    }

    public func update(with model: ProfileModel) {
        Configure(aboutMeLabel).asAboutMe().content(model).palette(paletteType)
        Configure(displayNameLabel).asDisplayName().content(model).palette(paletteType).font(.DS.headline)
        Configure(personalInfoLabel).asPersonalInfo().content(model).palette(paletteType)
        Configure(profileButton).asProfileButton().style(.view).alignment(.trailing).palette(paletteType)

        updateAccountButtons(with: model)
    }

    override public func update(with config: ProfileViewConfiguration) {
        super.update(with: config)
        guard let model = config.model else { return }
        update(with: model)
    }
}
