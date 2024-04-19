import UIKit
import Gravatar
import GravatarUI

open class BaseDemoProfileViewController: UIViewController {
    
    let emailField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "Email"
        textField.keyboardType = .emailAddress
        textField.autocapitalizationType = .none
        textField.textContentType = .emailAddress
        textField.textAlignment = .center
        return textField
    }()
    
    lazy var paletteButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Palette: \(preferredPaletteType.name)", for: .normal)
        button.addTarget(self, action: #selector(selectPalette), for: .touchUpInside)
        return button
    }()
    
    lazy var profileStylesButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Style: \(preferredProfileStyle.rawValue)", for: .normal)
        button.addTarget(self, action: #selector(selectProfileStyle), for: .touchUpInside)
        return button
    }()
    
    var preferredProfileStyle: ProfileViewConfiguration.Style = .standard {
        didSet {
            preferredProfileStyleChanged()
        }
    }
    
    let paletteTypes: [PaletteType] = [.system, .light, .dark]
    
    var preferredPaletteType: PaletteType = .system {
        didSet {
            preferredPaletteTypeChanged()
        }
    }

    open func preferredPaletteTypeChanged() { }
    open func preferredProfileStyleChanged() { }
    
    lazy var rootStackView: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 12
        stack.distribution = .fill
        stack.alignment = .fill
        return stack
    }()
    
    let scrollView: UIScrollView = {
        let view = UIScrollView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    open override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .secondarySystemBackground
        view.addSubview(scrollView)
        scrollView.addSubview(rootStackView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            rootStackView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            rootStackView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            rootStackView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            rootStackView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            rootStackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -40),
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
    
    @objc private func selectProfileStyle() {
        let controller = UIAlertController(title: "Layout Styles", message: nil, preferredStyle: .actionSheet)
        ProfileViewConfiguration.Style.allCases.forEach { option in
            controller.addAction(UIAlertAction(title: "\(option.rawValue)", style: .default) { [weak self] action in
                guard let title = action.title, let newStyle = ProfileViewConfiguration.Style(rawValue: title) else { return }
                self?.preferredProfileStyle = newStyle
                self?.profileStylesButton.setTitle("Style: \(self?.preferredProfileStyle.rawValue ?? "")", for: .normal)
            })
        }
        controller.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(controller, animated: true)
    }
}
