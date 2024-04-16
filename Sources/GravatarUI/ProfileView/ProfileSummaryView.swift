import Gravatar
import UIKit

public class ProfileSummaryView: ProfileComponentView {
    static let defaultPadding = UIEdgeInsets(
        top: .DS.Padding.split,
        left: .DS.Padding.medium,
        bottom: .DS.Padding.split,
        right: .DS.Padding.medium
    )

    private lazy var basicInfoStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [displayNameLabel, personalInfoLabel, profileButton])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        return stack
    }()

    public init(frame: CGRect, paletteType palette: PaletteType) {
        super.init(frame: frame, paletteType: palette, padding: Self.defaultPadding)

        rootStackView.axis = .horizontal
        rootStackView.alignment = .top

        [avatarImageView, basicInfoStackView].forEach(rootStackView.addArrangedSubview)
    }

    public func update(with model: ProfileSummaryModel) {
        Configure(displayNameLabel).asDisplayName().content(model).palette(paletteType).font(.DS.smallTitle)
        Configure(personalInfoLabel).asPersonalInfo().content(model, lines: [.init([.location])]).palette(paletteType)
        Configure(profileButton).asProfileButton().style(.view).palette(paletteType)
    }

    public override func update(with config: ProfileViewConfiguration) {
        super.update(with: config)
        guard let model = config.summaryModel else { return }
        update(with: model)
    }
}
