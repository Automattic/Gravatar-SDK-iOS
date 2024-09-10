import UIKit
import Gravatar

class DemoFetchProfileViewController: UIViewController {
    let rootStackView: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 12
        stack.distribution = .fill
        stack.alignment = .fill

        return stack
    }()

    lazy var segmentedControl: UISegmentedControl = {
        let control = UISegmentedControl(items: ["Email", "Hash"])
        control.addTarget(self, action: #selector(chooseFetchType(_:)), for: .valueChanged)
        control.selectedSegmentIndex = 0
        return control
    }()
    
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
    
    let hashField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "Hash"
        textField.keyboardType = .asciiCapable
        textField.autocapitalizationType = .none
        textField.textAlignment = .center
        return textField
    }()

    let fetchProfileButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Fetch Profile", for: .normal)
        button.contentHorizontalAlignment = .center
        return button
    }()

    let activityIndicator = UIActivityIndicatorView(style: .large)

    let profileTextView: UITextView = {
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.contentInsetAdjustmentBehavior = .never
        textView.isEditable = false
        return textView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Fetch Profile"
        view.backgroundColor = .white

        for view in [segmentedControl, emailField, fetchProfileButton, activityIndicator, profileTextView] {
            rootStackView.addArrangedSubview(view)
        }
        view.addSubview(rootStackView)

        NSLayoutConstraint.activate([
            view.safeAreaLayoutGuide.topAnchor.constraint(equalTo: rootStackView.topAnchor),
            view.readableContentGuide.leadingAnchor.constraint(equalTo: rootStackView.leadingAnchor),
            view.readableContentGuide.trailingAnchor.constraint(equalTo: rootStackView.trailingAnchor),
            view.safeAreaLayoutGuide.bottomAnchor.constraint(equalTo: rootStackView.bottomAnchor),
        ])

        fetchProfileButton.addTarget(self, action: #selector(fetchProfileButtonHandler), for: .touchUpInside)
    }

    @objc func fetchProfileButtonHandler() {
        var identifier: ProfileIdentifier
        
        guard activityIndicator.isAnimating == false else { return }
        
        if segmentedControl.selectedSegmentIndex == 0 {
            guard let email = emailField.text, email.isEmpty == false else { return }
            identifier = .email(email)
        } else {
            guard let hash = hashField.text, hash.isEmpty == false else { return }
            identifier = .hashID(hash)
        }
        
        profileTextView.text = nil
        activityIndicator.startAnimating()
        Task {
            await fetchProfile(with: identifier)
        }
    }

    func fetchProfile(with profileID: ProfileIdentifier) async {
        let service = ProfileService()
        do {
            let profile = try await service.fetch(with: profileID)
            setProfile(with: profile)
        } catch {
            showError(error)
        }
    }

    func setProfile(with profile: Profile) {
        activityIndicator.stopAnimating()
        profileTextView.text = """
Profile URL: \(profile.profileUrl)
Display name: \(profile.displayName)
Preferred User Name: \(profile.displayName)
Thumbnail URL: \(profile.avatarUrl)
Wallets: \(String(describing: profile.payments?.cryptoWallets))
Last edit: \(String(describing: profile.lastProfileEdit))
Registration date: \(String(describing: profile.registrationDate))
Interests: \(String(describing: profile.interests))
"""
    }

    func showError(_ error: Error) {
        DispatchQueue.main.async { [weak self] in
            self?.activityIndicator.stopAnimating()
            self?.profileTextView.text = String(describing: error)
        }
    }
    
    private enum FetchType: Int {
        case email = 0
        case hash
    }
    
    @objc private func chooseFetchType(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            setFetchType(.email)
        case 1:
            setFetchType(.hash)
        default:
            setFetchType(.email)
        }
    }
    
    private func setFetchType(_ type: FetchType) {
        switch type {
        case .email:
            if let index = rootStackView.arrangedSubviews.firstIndex(of: hashField) {
                rootStackView.removeArrangedSubview(hashField)
                hashField.removeFromSuperview()
                rootStackView.insertArrangedSubview(emailField, at: index)
            }
        case .hash:
            if let index = rootStackView.arrangedSubviews.firstIndex(of: emailField) {
                rootStackView.removeArrangedSubview(emailField)
                emailField.removeFromSuperview()
                rootStackView.insertArrangedSubview(hashField, at: index)
            }
        }
    }
}
