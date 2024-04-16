import Gravatar
import UIKit

public class ProfileSummaryView: ProfileComponentView {
    private lazy var basicInfoStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [displayNameLabel, personalInfoLabel, profileButton])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        return stack
    }()

    override public init(frame: CGRect, paletteType palette: PaletteType, padding: UIEdgeInsets? = nil) {
        super.init(frame: frame, paletteType: palette, padding: padding)

        rootStackView.axis = .horizontal
        rootStackView.alignment = .top

        [avatarImageView, basicInfoStackView].forEach(rootStackView.addArrangedSubview)
    }

    public func update(with model: ProfileSummaryModel) {
        Configure(displayNameLabel).asDisplayName().content(model).palette(paletteType).font(.DS.smallTitle)
        Configure(personalInfoLabel).asPersonalInfo().content(model, lines: [.init([.location])]).palette(paletteType)
        Configure(profileButton).asProfileButton().style(.view).palette(paletteType)
    }

    override public func update(with config: ProfileViewConfiguration) {
        super.update(with: config)
        guard let model = config.summaryModel else { return }
        update(with: model)
    }
}
