import UIKit

@MainActor
class DefaultAvatarProvider: AvatarProviding {
    private let avatarLength: CGFloat
    private let avatarImageView: UIImageView
    private let baseView: UIView
    private let skipStyling: Bool
    private(set) var paletteType: PaletteType

    var avatarCornerRadius: CGFloat {
        didSet {
            avatarImageView.layer.cornerRadius = avatarCornerRadius
        }
    }

    var avatarBorderWidth: CGFloat {
        didSet {
            avatarImageView.layer.borderWidth = avatarBorderWidth
        }
    }

    var activityIndicatorType: ActivityIndicatorType = .activity {
        didSet {
            avatarImageView.gravatar.activityIndicatorType = activityIndicatorType
        }
    }

    init(
        baseView: UIView,
        avatarImageView: UIImageView,
        skipStyling: Bool,
        avatarLength: CGFloat,
        cornerRadius: CGFloat? = nil,
        borderWidth: CGFloat = 1,
        paletteType: PaletteType = .system
    ) {
        self.avatarLength = avatarLength
        self.paletteType = paletteType
        self.avatarCornerRadius = cornerRadius ?? avatarLength / 2
        self.avatarBorderWidth = borderWidth
        self.avatarImageView = avatarImageView
        self.baseView = baseView
        self.skipStyling = skipStyling
        configure()
    }

    private func configure() {
        guard !skipStyling else { return }
        baseView.translatesAutoresizingMaskIntoConstraints = false
        baseView.widthAnchor.constraint(equalToConstant: avatarLength).isActive = true
        baseView.heightAnchor.constraint(equalToConstant: avatarLength).isActive = true
        avatarImageView.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        avatarImageView.layer.cornerRadius = avatarCornerRadius
        avatarImageView.clipsToBounds = true
    }

    func setImage(with source: URL?, placeholder: UIImage?, options: [ImageSettingOption]?) async throws {
        do {
            let _ = try await avatarImageView.gravatar.setImage(with: source, placeholder: placeholder, options: options)
            if !skipStyling {
                avatarImageView.layer.borderColor = paletteType.palette.avatar.border.cgColor
                avatarImageView.layer.borderWidth = avatarBorderWidth
            }
        } catch {
            if !skipStyling {
                avatarImageView.layer.borderColor = UIColor.clear.cgColor
            }
            throw error
        }
    }

    func setImage(_ image: UIImage?) {
        avatarImageView.image = image
    }

    func refresh(with paletteType: PaletteType) {
        guard !skipStyling else { return }
        self.paletteType = paletteType
        avatarImageView.layer.borderColor = paletteType.palette.avatar.border.cgColor
        avatarImageView.backgroundColor = paletteType.palette.avatar.background
        avatarImageView.overrideUserInterfaceStyle = paletteType.palette.preferredUserInterfaceStyle
    }

    var avatarView: UIView {
        baseView
    }
}
