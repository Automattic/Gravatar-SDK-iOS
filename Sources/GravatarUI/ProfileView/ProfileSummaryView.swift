import Gravatar
import UIKit

public class ProfileSummaryView: BaseProfileView {
    private lazy var basicInfoStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [displayNameLabel, personalInfoLabel, profileButton])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.alignment = .leading
        return stack
    }()

    private lazy var contentStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [avatarImageView, basicInfoStackView])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = .DS.Padding.single
        return stack
    }()

    override public func arrangeSubviews() {
        super.arrangeSubviews()
        [contentStackView, .spacer()].forEach(rootStackView.addArrangedSubview)
        setStackViewSpacing()
    }

    private func setStackViewSpacing() {
        rootStackView.spacing = 0
        basicInfoStackView.spacing = 0
    }

    public func update(with model: ProfileSummaryModel?) {
        self.model = model
        guard let model else { return }
        Configure(displayNameLabel).asDisplayName().content(model).palette(paletteType).font(.DS.headline)
        Configure(personalInfoLabel).asPersonalInfo().content(model, lines: [.init([.location])]).palette(paletteType)
        Configure(profileButton).asProfileButton().style(profileButtonStyle).palette(paletteType)
    }

    override public func update(with config: ProfileViewConfiguration) {
        super.update(with: config)
        update(with: config.summaryModel)
    }

    override public func showPlaceholders() {
        super.showPlaceholders()
        basicInfoStackView.spacing = .DS.Padding.single
    }

    override public func hidePlaceholders() {
        super.hidePlaceholders()
        setStackViewSpacing()
    }
}
