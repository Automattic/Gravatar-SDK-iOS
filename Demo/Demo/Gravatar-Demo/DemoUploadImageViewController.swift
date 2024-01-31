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

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Upload Image"
        view.backgroundColor = .white

        [emailField, tokenField, selectImageButton, avatarImageView, uploadImageButton, activityIndicator, resultLabel].forEach(rootStackView.addArrangedSubview)
        view.addSubview(rootStackView)

        NSLayoutConstraint.activate([
            view.safeAreaLayoutGuide.topAnchor.constraint(equalTo: rootStackView.topAnchor),
            view.readableContentGuide.leadingAnchor.constraint(equalTo: rootStackView.leadingAnchor),
            view.readableContentGuide.trailingAnchor.constraint(equalTo: rootStackView.trailingAnchor),
        ])

        uploadImageButton.addTarget(self, action: #selector(fetchProfileButtonHandler), for: .touchUpInside)
        selectImageButton.addTarget(self, action: #selector(selectImage), for: .touchUpInside)
    }

    @objc func selectImage(_ sender: UIButton) {
        let picker = UIImagePickerController()
        picker.allowsEditing = true
        picker.delegate = self
        present(picker, animated: true)
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

        let service = GravatarService()
//        let service = Gravatar.ImageService()
        service.uploadImage(image, accountEmail: email, accountToken: token) { [weak self] error in
            DispatchQueue.main.async {
                self?.uploadResult(with: error)
            }
        }
    }

    func uploadResult(with error: Error?) {
        activityIndicator.stopAnimating()
        if let error = error as? NSError {
            print("Error: \(error)")
            resultLabel.text = "Error \(error.code): \(error.localizedDescription)"
        } else {
            resultLabel.text = "Success! 🎉"
        }
    }
}

extension DemoUploadImageViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.editedImage] as? UIImage else { return }
        avatarImageView.image = image

        dismiss(animated: true)
    }
}
