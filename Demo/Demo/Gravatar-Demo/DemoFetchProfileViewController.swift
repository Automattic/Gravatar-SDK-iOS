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

        [emailField, fetchProfileButton, activityIndicator, profileTextView].forEach(rootStackView.addArrangedSubview)
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
        guard activityIndicator.isAnimating == false, let email = emailField.text, email.isEmpty == false else {
            return
        }
        profileTextView.text = nil
        activityIndicator.startAnimating()
        let service = Gravatar.ProfileService()
        service.fetchProfile(with: email) { [weak self] result in
            switch result {
            case .success(let profile):
                self?.setProfile(with: profile)
            case .failure(let error):
                self?.showError(error)
            }
        }
    }

    func setProfile(with profile: UserProfile) {
        DispatchQueue.main.async { [weak self] in
            self?.activityIndicator.stopAnimating()
            self?.profileTextView.text = """
Profile URL: \(profile.profileURL?.absoluteString ?? "")
Display name: \(profile.displayName)
Name: \(profile.displayName)
Preferred User Name: \(profile.preferredUsername)
Thumbnail URL: \(profile.thumbnailURL?.absoluteString ?? "")
Last edit: \(String(describing: profile.lastProfileEdit))
"""
        }
    }

    func showError(_ error: Error) {
        DispatchQueue.main.async { [weak self] in
            self?.activityIndicator.stopAnimating()
            self?.profileTextView.text = String(describing: error)
        }
    }
}
