import UIKit
import Gravatar
import GravatarUI

class DemoLargeProfileViewController: UIViewController {
    
    lazy var emailField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "Email"
        textField.keyboardType = .emailAddress
        textField.autocapitalizationType = .none
        textField.textContentType = .emailAddress
        textField.textAlignment = .center
        return textField
    }()
    
    lazy var fetchProfileButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Fetch Profile", for: .normal)
        button.contentHorizontalAlignment = .center
        button.addTarget(self, action: #selector(fetchProfileButtonHandler), for: .touchUpInside)
        return button
    }()

    let activityIndicator = UIActivityIndicatorView(style: .large)

    lazy var largeProfileView: LargeProfileView = {
        let view = LargeProfileView(frame: .zero, paletteType: preferredPaletteType)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.avatarImageView.gravatar.activityIndicatorType = .activity
        return view
    }()
    
    lazy var rootStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [emailField, paletteButton, fetchProfileButton, activityIndicator])
        
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 12
        stack.distribution = .fill
        stack.alignment = .fill

        return stack
    }()

    private lazy var paletteButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Palette: \(preferredPaletteType.name)", for: .normal)
        button.addTarget(self, action: #selector(selectPalette), for: .touchUpInside)
        return button
    }()
    
    let paletteTypes: [PaletteType] = [.system, .light, .dark]
    
    var preferredPaletteType: PaletteType = .system {
        didSet {
            largeProfileView.paletteType = preferredPaletteType
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Fetch Profile"
        self.edgesForExtendedLayout = []
        view.backgroundColor = .white
        view.addSubview(rootStackView)
        view.addSubview(largeProfileView)
        
        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: rootStackView.topAnchor, constant: -20),
            view.leadingAnchor.constraint(equalTo: rootStackView.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: rootStackView.trailingAnchor),
            largeProfileView.containerLayoutGuide.leadingAnchor.constraint(equalTo: rootStackView.leadingAnchor, constant: 30),
            largeProfileView.containerLayoutGuide.trailingAnchor.constraint(equalTo: rootStackView.trailingAnchor, constant: -30),
            largeProfileView.containerLayoutGuide.topAnchor.constraint(equalTo: rootStackView.bottomAnchor),
        ])
    }
    
    @objc private func selectPalette() {
        let controller = UIAlertController(title: "Palette", message: nil, preferredStyle: .actionSheet)

        paletteTypes.forEach { option in
            controller.addAction(UIAlertAction(title: "\(option.name)", style: .default) { [weak self] action in
                guard let title = action.title else { return }
                switch title {
                case PaletteType.system.name:
                    self?.preferredPaletteType = PaletteType.system
                case PaletteType.light.name:
                    self?.preferredPaletteType = PaletteType.light
                case PaletteType.dark.name:
                    self?.preferredPaletteType = PaletteType.dark
                default:
                    self?.preferredPaletteType = PaletteType.system
                }
                self?.paletteButton.setTitle("Palette: \(self?.preferredPaletteType.name ?? "")", for: .normal)
            })
        }

        controller.addAction(UIAlertAction(title: "Cancel", style: .cancel))

        present(controller, animated: true)
    }

    
    @objc func fetchProfileButtonHandler() {
        var identifier: ProfileIdentifier
        guard let email = emailField.text, email.isEmpty == false else { return }
        identifier = .email(email)

        guard activityIndicator.isAnimating == false else { return }
        
        activityIndicator.startAnimating()
        let service = ProfileService()
        Task {
            do {
                let profile = try await service.fetch(with: identifier)
                activityIndicator.stopAnimating()
                largeProfileView.update(with: profile)
                largeProfileView.loadAvatar(with: profile.avatarIdentifier, options: [.transition(.fade(0.2))])
            } catch {
                activityIndicator.stopAnimating()
                print(error)
            }
        }
    }
}
