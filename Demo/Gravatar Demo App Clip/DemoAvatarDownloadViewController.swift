import UIKit
import Gravatar

class DemoAvatarDownloadViewController: BaseFormViewController {
    static let imageViewSize: CGFloat = 300

    let ignoreCacheSwitch = SwitchField(title: "Ignore cache", isOn: false)
    let forceDefaultSwitch = SwitchField(title: "Force default avatar", isOn: false)
    let emailField = TextFormField(placeholder: "Enter Gravatar Email", keyboardType: .emailAddress)
    let hashField = TextFormField(placeholder: "Enter a valid Gravatar Hash", keyboardType: .asciiCapable)
    let avatarLengthField = TextFormField(placeholder: "Preferred avatar length (optional)", keyboardType: .numberPad)
    let ratingField = TextFormField(placeholder: "Gravatar rating (optional) - [g|pg|r|x]")
    let customDefaultURLField = TextFormField(placeholder: "Set custom avatar default URL")
    let avatarImageField = ImageFormField(image: nil, size: .init(width: imageViewSize, height: imageViewSize))

    lazy var idTypeSelector = SegmentedControlField(
        segments: ["Email", "Hash"]
    ) {[weak self] _, index in
        self?.selectIDField(for: index)
    }

    lazy var defaultOptionButton = ButtonLabelField(
        title: "Default Avatar Option:",
        subtitle: "Backend driven",
        buttonTitle: "Select"
    ) { [weak self] _ in
        self?.selectImageDefault()
    }

    lazy var fetchButton = ButtonField(
        title: "Fetch Avatar",
        isActionButton: true
    ) { [weak self] _ in
        self?.fetchAvatarButtonHandler()
    }

    override var form: [FormField] {
        [
            idTypeSelector,
            emailField,
            avatarLengthField,
            ratingField,
            forceDefaultSwitch,
            ignoreCacheSwitch,
            defaultOptionButton,
            customDefaultURLField,
            fetchButton,
            avatarImageField
        ]
    }

    private let imageRetriever = Gravatar.AvatarService()

    override func viewDidLoad() {
        super.viewDidLoad()

        customDefaultURLField.$didEndEditingText.sink { [weak self] text in
            self?.didEndEditingCustomDefaultURLField(with: text)
        }.store(in: &cancellables)
    }

    func selectIDField(for index: Int) {
        if index == 0 {
            replace(hashField, with: emailField, after: idTypeSelector)
        } else {
            replace(emailField, with: hashField, after: idTypeSelector)
        }
    }

    func didEndEditingCustomDefaultURLField(with text: String) {
        guard
            let url = URL(string: text),
            // Check if the URL is valid.
            UIApplication.shared.canOpenURL(url)
        else {
            customDefaultURLField.text = ""
            update(customDefaultURLField)
            return
        }

        defaultOptionButton.subtitle = "Custom URL"
        customDefaultURLField.text = url.absoluteString
        preferredDefaultAvatar = .customURL(url)
        update([defaultOptionButton, customDefaultURLField])
    }

    private var preferredSize: CGFloat {
        let preferredLenghtStr = avatarLengthField.text
        if
           !preferredLenghtStr.isEmpty,
           let preferredSize = Float(preferredLenghtStr)
        {
            return CGFloat(preferredSize)
        }
        return Self.imageViewSize
    }
    
    private var preferredRating: Rating? {
        let ratingStr = ratingField.text
        if !ratingStr.isEmpty {
            return Rating(rawValue: ratingStr)
        }
        return nil
    }

    private var preferredDefaultAvatar: DefaultAvatarOption? = nil

    @objc private func selectImageDefault() {
        let controller = UIAlertController(title: "Default Avatar Option", message: nil, preferredStyle: .actionSheet)

        DefaultAvatarOption.allCases.forEach { option in
            controller.addAction(UIAlertAction(title: "\(option)", style: .default) { [weak self] action in
                guard let self else { return }
                self.preferredDefaultAvatar = option
                self.defaultOptionButton.subtitle = "\(option)"
                self.customDefaultURLField.text = ""
                self.update([defaultOptionButton, customDefaultURLField])
            })
        }

        controller.addAction(UIAlertAction(title: "Cancel", style: .cancel))

        present(controller, animated: true)
    }

    @objc private func fetchAvatarButtonHandler() {
        let options: ImageDownloadOptions = .init(
            preferredSize: .points(preferredSize),
            rating: preferredRating,
            forceRefresh: ignoreCacheSwitch.isOn,
            forceDefaultAvatar: forceDefaultSwitch.isOn,
            defaultAvatarOption: preferredDefaultAvatar
        )

        avatarImageField.image = nil // Setting to nil to make the effect of `forceRefresh more visible
        update(avatarImageField)

        let identifier: AvatarIdentifier
        if idTypeSelector.selectedIndex == 0 {
            let email = emailField.text
            guard email.isEmpty == false else { return }
            identifier = .email(email)
        } else {
            let hash = hashField.text
            guard hash.isEmpty == false else { return }
            identifier = .hashID(hash)
        }
        
        Task {
            do {
                let result = try await imageRetriever.fetch(with: identifier, options: options)
                avatarImageField.image = result.image
                update(avatarImageField)

            } catch {
                print(error)
            }
        }
    }
    
    private enum FetchType: Int {
        case email = 0
        case hash
    }
}
