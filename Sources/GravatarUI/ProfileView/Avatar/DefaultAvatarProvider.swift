import UIKit

@MainActor
class DefaultAvatarProvider: AvatarProviding {
    private let avatarImageView: UIImageView
    private let baseView: UIView
    private let skipStyling: Bool
    private(set) var paletteType: PaletteType
    private var widthConstraint: NSLayoutConstraint?
    private var heightConstraint: NSLayoutConstraint?

    var cornerRadiusCalculator: AvatarCornerRadiusCalculator {
        didSet {
            avatarCornerRadius = cornerRadiusCalculator(avatarLength)
        }
    }

    var avatarLength: CGFloat {
        didSet {
            guard avatarLength != oldValue else { return }
            avatarCornerRadius = cornerRadiusCalculator(avatarLength)
            applyLength()
        }
    }

    private var avatarCornerRadius: CGFloat {
        didSet {
            applyCornerRadius()
        }
    }

    var avatarBorderWidth: CGFloat {
        didSet {
            applyBorderWidth()
        }
    }

    var avatarBorderColor: UIColor? {
        didSet {
            applyBorderColor()
        }
    }

    var activityIndicatorType: ActivityIndicatorType = .activity {
        didSet {
            avatarImageView.gravatar.activityIndicatorType = activityIndicatorType
        }
    }

    private func applyAvatarActivityIndicatorTintColor() {
        guard !skipStyling else { return }
        avatarImageView.gravatar.activityIndicator?.view.tintColor = paletteType.palette.foreground.secondary
    }

    private func applyBorderWidth() {
        guard !skipStyling else { return }
        avatarImageView.layer.borderWidth = avatarBorderWidth
    }

    private func applyBorderColor() {
        guard !skipStyling else { return }
        avatarImageView.layer.borderColor = (avatarBorderColor ?? paletteType.palette.avatar.border).cgColor
    }

    private func applyCornerRadius() {
        guard !skipStyling else { return }
        avatarImageView.layer.cornerRadius = avatarCornerRadius
    }

    private func applyLength() {
        guard !skipStyling else { return }
        widthConstraint?.isActive = false
        heightConstraint?.isActive = false
        widthConstraint = baseView.widthAnchor.constraint(equalToConstant: avatarLength)
        heightConstraint = baseView.heightAnchor.constraint(equalToConstant: avatarLength)
        widthConstraint?.isActive = true
        heightConstraint?.isActive = true
    }

    init(
        baseView: UIView,
        avatarImageView: UIImageView,
        skipStyling: Bool,
        avatarLength: CGFloat,
        cornerRadiusCalculator: AvatarCornerRadiusCalculator? = nil,
        borderWidth: CGFloat = 1,
        paletteType: PaletteType = .system
    ) {
        self.avatarLength = avatarLength
        self.paletteType = paletteType
        self.cornerRadiusCalculator = cornerRadiusCalculator ?? AvatarConstants.cornerRadiusCalculator
        self.avatarCornerRadius = self.cornerRadiusCalculator(avatarLength)
        self.avatarBorderWidth = borderWidth
        self.avatarImageView = avatarImageView
        self.baseView = baseView
        self.skipStyling = skipStyling
        configure()
    }

    private func configure() {
        guard !skipStyling else { return }
        baseView.translatesAutoresizingMaskIntoConstraints = false
        avatarImageView.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        avatarImageView.setContentHuggingPriority(.defaultHigh, for: .vertical)
        applyLength()
        applyBorderWidth()
        applyBorderColor()
        applyCornerRadius()
        applyAvatarActivityIndicatorTintColor()
        avatarImageView.clipsToBounds = true
    }

    func setImage(with source: URL?, placeholder: UIImage?, options: [ImageSettingOption]?) async throws {
        try await avatarImageView.gravatar.setImage(with: source, placeholder: placeholder, options: options)
    }

    func setImage(_ image: UIImage?) {
        avatarImageView.image = image
    }

    func refresh(with paletteType: PaletteType) {
        guard !skipStyling else { return }
        self.paletteType = paletteType
        applyBorderColor()
        applyAvatarActivityIndicatorTintColor()
        avatarImageView.backgroundColor = paletteType.palette.avatar.background
        avatarImageView.overrideUserInterfaceStyle = paletteType.palette.preferredUserInterfaceStyle
    }

    var avatarView: UIView {
        baseView
    }
}
