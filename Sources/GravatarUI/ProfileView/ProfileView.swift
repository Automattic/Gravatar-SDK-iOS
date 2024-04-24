import Gravatar
import UIKit

/// ![](profileView.view)
/// A profile view with standard layout
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
        let stack = UIStackView(arrangedSubviews: [accountButtonsStackView, profileButton])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.distribution = .equalCentering
        stack.spacing = .DS.Padding.split
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
        [topStackView, aboutMeLabel, bottomStackView].forEach(rootStackView.addArrangedSubview)
        rootStackView.setCustomSpacing(.DS.Padding.double, after: aboutMeLabel)
    }

    public func update(with model: ProfileModel) {
        Configure(aboutMeLabel).asAboutMe().content(model).palette(paletteType)
        Configure(displayNameLabel).asDisplayName().content(model).palette(paletteType).font(.DS.headline)
        Configure(personalInfoLabel).asPersonalInfo().content(model).palette(paletteType)
        Configure(profileButton).asProfileButton().style(profileButtonStyle).alignment(.trailing).palette(paletteType)
        profileMetadata = model
        updateAccountButtons(with: model)
    }

    override public func update(with config: ProfileViewConfiguration) {
        super.update(with: config)
        guard let model = config.model else { return }
        update(with: model)
    }
}
