import Gravatar
import UIKit

public class LargeProfileView: BaseProfileView {
    private enum Constants {
        static let avatarLength: CGFloat = 132.0
        static let displayNamePlaceholderHeight: CGFloat = 32
    }

    override public var avatarLength: CGFloat {
        Constants.avatarLength
    }

    private lazy var topStackView: UIStackView = {
        let spacer = UIView()
        spacer.translatesAutoresizingMaskIntoConstraints = false
        spacer.setContentHuggingPriority(.defaultLow, for: .vertical)
        let stack = UIStackView(arrangedSubviews: [avatarImageView, spacer])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        return stack
    }()

    private lazy var bottomStackView: UIStackView = {
        let spacer = UIView()
        spacer.translatesAutoresizingMaskIntoConstraints = false
        spacer.setContentHuggingPriority(.defaultLow, for: .vertical)
        let stack = UIStackView(arrangedSubviews: [accountButtonsStackView, spacer, profileButton])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = .DS.Padding.split
        return stack
    }()

    override public init(frame: CGRect) {
        super.init(frame: frame)
        [topStackView, displayNameLabel, personalInfoLabel, aboutMeLabel, aboutMePlaceholderLabel, bottomStackView].forEach(rootStackView.addArrangedSubview)
        setRootStackViewSpacing()
    }
    
    private func setRootStackViewSpacing() {
        rootStackView.setCustomSpacing(.DS.Padding.double, after: avatarImageView)
        rootStackView.setCustomSpacing(0, after: displayNameLabel)
        rootStackView.setCustomSpacing(.DS.Padding.double, after: aboutMeLabel)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public func update(with model: ProfileModel?) {
        isEmpty = model == nil
        guard let model else { return }
        Configure(aboutMeLabel).asAboutMe().content(model).palette(paletteType)
        Configure(displayNameLabel).asDisplayName().content(model).palette(paletteType)
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
        rootStackView.setCustomSpacing(.DS.Padding.split, after: displayNameLabel)
        rootStackView.setCustomSpacing(.DS.Padding.medium, after: personalInfoLabel)
        rootStackView.setCustomSpacing(.DS.Padding.single, after: aboutMeLabel)
        rootStackView.setCustomSpacing(.DS.Padding.double, after: aboutMePlaceholderLabel)
    }
    
    public override func hidePlaceholders() {
        super.hidePlaceholders()
        setRootStackViewSpacing()
    }
    
    override public var displayNamePlaceholderHeight: CGFloat {
        Constants.displayNamePlaceholderHeight
    }
}
