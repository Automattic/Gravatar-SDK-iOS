import UIKit
import Gravatar

class DemoUploadImageViewController: UIViewController {
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
    
    lazy var avatarSelectionButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Upload version: " + avatarUploadVersion.rawValue, for: .normal)
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
        imageView.backgroundColor = .lightGray
        return imageView
    }()

    let activityIndicator = UIActivityIndicatorView(style: .large)

    let resultLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        return label
    }()
    
    private var avatarUploadVersion: AvatarUploadVersion = .v3

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Upload Image"
        view.backgroundColor = .white

        for view in [emailField, tokenField, avatarSelectionButton, selectImageButton, avatarImageView, uploadImageButton, activityIndicator, resultLabel] {
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
                switch avatarUploadVersion {
                    case .v1:
                        let response = try await service.upload(image, email: .init(email), accessToken: token)
                        resultLabel.text = "✅ New V1 avatar status: \((response as? HTTPURLResponse)?.statusCode ?? -1)"
                    case .v3:
                        let avatarModel = try await service.upload(image, accessToken: token)
                        resultLabel.text = "✅ New V3 avatar id \(avatarModel.id)"
                }
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

        let squareImage = makeSquare(image)
        avatarImageView.image = squareImage

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
        let controller = UIAlertController(title: "Upload version:", message: nil, preferredStyle: .actionSheet)

        AvatarUploadVersion.allCases.forEach { selectionCase in
            controller.addAction(UIAlertAction(title: selectionCase.rawValue, style: .default) { [weak self] action in
                self?.avatarUploadVersion = selectionCase
                self?.avatarSelectionButton.setTitle("Upload version: \(selectionCase.rawValue)", for: .normal)
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
