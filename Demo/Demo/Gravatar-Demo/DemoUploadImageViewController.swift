import UIKit
import Gravatar

class DemoUploadImageViewController: UIViewController, UITextFieldDelegate {
    private enum Constant {
        static let aspectFillMinSquarenessDefaultValue: CGFloat = 0.98
    }
    
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

    let tokenField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "Token"
        textField.autocapitalizationType = .none
        textField.textAlignment = .center
        textField.isSecureTextEntry = true
        return textField
    }()
    
    let squaringLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Square:"
        label.font = .preferredFont(forTextStyle: .body)
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    let segmentedControl: UISegmentedControl = {
        let segmentedControl = UISegmentedControl(items: ["Selection", "On upload"])
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        segmentedControl.selectedSegmentIndex = 0
        return segmentedControl
    }()
    
    let aspectFillMinSquarenessLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Min:"
        label.font = .preferredFont(forTextStyle: .body)
        label.textColor = .label
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    let aspectFillMinSquarenessField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.text = "\(Constant.aspectFillMinSquarenessDefaultValue)"
        textField.keyboardType = .decimalPad
        textField.autocapitalizationType = .none
        textField.textAlignment = .right
        textField.borderStyle = .roundedRect
        textField.isEnabled = false
        textField.isUserInteractionEnabled = false
        textField.textColor = .label.withAlphaComponent(0.5)
        return textField
    }()
    
    let squaringStackView: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.spacing = 5
        stack.distribution = .fillProportionally
        stack.alignment = .fill
        
        return stack
    }()
    
    lazy var avatarSelectionButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(avatarSelectionBehavior.description, for: .normal)
        button.contentHorizontalAlignment = .center
        button.isEnabled = false
        return button
    }()

    let selectImageButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Select Image", for: .normal)
        button.contentHorizontalAlignment = .center
        return button
    }()

    let uploadImageButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Upload Image", for: .normal)
        button.contentHorizontalAlignment = .center
        return button
    }()

    let avatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.heightAnchor.constraint(equalToConstant: 300).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: 300).isActive = true
        imageView.backgroundColor = .clear
        imageView.layer.borderWidth = 1
        imageView.layer.borderColor = UIColor.lightGray.cgColor
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    let activityIndicator = UIActivityIndicatorView(style: .large)

    let resultLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        return label
    }()

    private var avatarSelectionBehavior: AvatarSelection = .preserveSelection
    private var aspectFillMinSquarenessValue: CGFloat = Constant.aspectFillMinSquarenessDefaultValue
    private var imageSquaringMechanism: SquaringMechanism = .imagePickerController
    private var squaringStrategy: SquaringStrategy {
        switch imageSquaringMechanism {
        case .imagePickerController:
            return .none
        case .onUpload:
            return .default
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Upload Image"
        view.backgroundColor = .systemBackground

        for view in [squaringLabel, segmentedControl, aspectFillMinSquarenessLabel, aspectFillMinSquarenessField] {
            squaringStackView.addArrangedSubview(view)
        }
        
        for view in [emailField, tokenField, squaringStackView, avatarSelectionButton, selectImageButton, avatarImageView, uploadImageButton, activityIndicator, resultLabel] {
            rootStackView.addArrangedSubview(view)
        }
        view.addSubview(rootStackView)

        NSLayoutConstraint.activate([
            view.safeAreaLayoutGuide.topAnchor.constraint(equalTo: rootStackView.topAnchor),
            view.readableContentGuide.leadingAnchor.constraint(equalTo: rootStackView.leadingAnchor),
            view.readableContentGuide.trailingAnchor.constraint(equalTo: rootStackView.trailingAnchor),
        ])

        emailField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        uploadImageButton.addTarget(self, action: #selector(fetchProfileButtonHandler), for: .touchUpInside)
        selectImageButton.addTarget(self, action: #selector(selectImage), for: .touchUpInside)
        segmentedControl.addTarget(self, action: #selector(segmentedControllerValueChanged(_:)), for: .valueChanged)
        aspectFillMinSquarenessField.addTarget(self, action: #selector(thresholdEditingDidEnd(_:)), for: .editingChanged)
    }
    
    @objc func segmentedControllerValueChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            aspectFillMinSquarenessField.isEnabled = false
            aspectFillMinSquarenessField.isUserInteractionEnabled = false
            aspectFillMinSquarenessField.textColor = .label.withAlphaComponent(0.5)
            imageSquaringMechanism = .imagePickerController
        case 1:
            aspectFillMinSquarenessField.isEnabled = true
            aspectFillMinSquarenessField.isUserInteractionEnabled = true
            aspectFillMinSquarenessField.textColor = .label
            imageSquaringMechanism = .onUpload
        default:
            return
        }
    }
    
    @objc func thresholdEditingDidEnd(_ sender: UITextField) {
        guard let aspectFillMinSquarenessString = aspectFillMinSquarenessField.text,
              aspectFillMinSquarenessString.isEmpty == false else {
            self.aspectFillMinSquarenessValue = Constant.aspectFillMinSquarenessDefaultValue
            return
        }
        
        self.aspectFillMinSquarenessValue = CGFloat(aspectFillMinSquarenessString) ?? Constant.aspectFillMinSquarenessDefaultValue
    }
    
    @objc func selectImage(_ sender: UIButton) {
        let picker = UIImagePickerController()
        picker.allowsEditing = true
        picker.delegate = self
        present(picker, animated: true)
    }
    
    @objc func textFieldDidChange(_ sender: UITextField) {
        if emailField.text?.isEmpty == true {
            avatarSelectionButton.isEnabled = false
        } else {
            avatarSelectionButton.isEnabled = true
            avatarSelectionButton.removeTarget(nil, action: nil, for: .touchUpInside)
            avatarSelectionButton.addTarget(self, action: #selector(avatarSelectionTapped), for: .touchUpInside)
        }
    }

    @objc func fetchProfileButtonHandler() {
        guard 
            activityIndicator.isAnimating == false,
            let email = emailField.text, email.isEmpty == false,
            let token = tokenField.text, token.isEmpty == false,
            let image = avatarImageView.image
        else {
            return
        }
        
        activityIndicator.startAnimating()
        resultLabel.text = nil

        let service = Gravatar.AvatarService()

        Task {
            do {
                let avatarModel = try await service.upload(image, selectionBehavior: avatarSelectionBehavior, accessToken: token, squaringStrategy: squaringStrategy)
                resultLabel.text = "✅ Avatar id \(avatarModel.id)"
            } catch {
                resultLabel.text = "Error \((error as NSError).code): \(error.localizedDescription)"
            }
            activityIndicator.stopAnimating()
        }
    }
}

extension DemoUploadImageViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.editedImage] as? UIImage else { return }

        switch imageSquaringMechanism {
        case .imagePickerController:
            avatarImageView.image = makeSquare(image)
        case .onUpload:
            avatarImageView.image = image
        }

        dismiss(animated: true)
    }

    /// Squares the given image by fitting it into a square shape.
    /// Think of it as the mode "aspect fit".
    private func makeSquare(_ image: UIImage) -> UIImage {
        let squareSide = max(image.size.height, image.size.width)
        let squareSize = CGSize(width: squareSide, height: squareSide)
        let imageOrigin = CGPoint(x: (squareSide - image.size.width) / 2, y: (squareSide - image.size.height) / 2)

        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        return UIGraphicsImageRenderer(size: squareSize, format: format).image { context in
            UIColor.black.setFill()
            context.fill(CGRect(origin: .zero, size: squareSize))
            image.draw(in: CGRect(origin: imageOrigin, size: image.size))
        }
    }
    
    @objc private func avatarSelectionTapped() {
        if let email = emailField.text {
            setAvatarSelectionMethod(with: email)
        }
    }
    
    @objc private func setAvatarSelectionMethod(with email: String) {
        guard let email = emailField.text else { return }

        let controller = UIAlertController(title: "Avatar selection behavior:", message: nil, preferredStyle: .actionSheet)


        AvatarSelection.allCases(for: .init(email)).forEach { selectionCase in
            controller.addAction(UIAlertAction(title: selectionCase.description, style: .default) { [weak self] action in
                self?.avatarSelectionBehavior = selectionCase
                self?.avatarSelectionButton.setTitle(selectionCase.description, for: .normal)
            })
        }

        controller.addAction(UIAlertAction(title: "Cancel", style: .cancel))

        present(controller, animated: true)
    }
}

enum AvatarUploadVersion: String, CaseIterable {
    case v1
    case v3
}

extension AvatarSelection {
    var description: String {
        switch self {
            case .selectUploadedImage: return "Select uploaded image"
            case .preserveSelection: return "Preserve selection"
            case .selectUploadedImageIfNoneSelected: return "Select uploaded image if none selected"
        }
    }
}

extension CGFloat {
    init?(_ value: String?) {
        guard let value, let doubleValue = Double(value) else { return nil }
        self.init(doubleValue)
    }
}

private enum SquaringMechanism {
    case imagePickerController
    case onUpload
}
