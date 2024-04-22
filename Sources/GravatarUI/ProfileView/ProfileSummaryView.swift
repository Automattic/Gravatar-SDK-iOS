import Gravatar
import UIKit

public class ProfileSummaryView: BaseProfileView {
    private lazy var basicInfoStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [displayNameLabel, personalInfoLabel, profileButton])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        return stack
    }()

    override public init(frame: CGRect) {
        super.init(frame: frame)
        rootStackView.axis = .horizontal
        rootStackView.alignment = .center
        [avatarImageView, basicInfoStackView].forEach(rootStackView.addArrangedSubview)
    }

    public func update(with model: ProfileSummaryModel) {
        Configure(displayNameLabel).asDisplayName().content(model).palette(paletteType).font(.DS.headline)
        Configure(personalInfoLabel).asPersonalInfo().content(model, lines: [.init([.location])]).palette(paletteType)
        Configure(profileButton).asProfileButton().style(.view).palette(paletteType)
    }

    override public func update(with config: ProfileViewConfiguration) {
        super.update(with: config)
        guard let model = config.summaryModel else { return }
        update(with: model)
    }
}
