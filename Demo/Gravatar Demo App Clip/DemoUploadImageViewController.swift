import UIKit
import Gravatar
import Combine

class DemoUploadImageViewController: BaseFormViewController {
    let emailFormField = TextFormField(placeholder: "Email", keyboardType: .emailAddress)
    let tokenFormField = TextFormField(placeholder: "Token", isSecure: true)
    let avatarImageField = ImageFormField(size: .init(width: 300, height: 300))
    let resultField = LabelField(title: "", subtitle: "")

    lazy var backendSelectionBehaviorButtonField = ButtonLabelField(
        title: "Backend selection behavior",
        subtitle: "Preserve selection",
        buttonTitle: "Select"
    ) { [weak self] _ in
        self?.avatarSelectionTapped()
    }

    lazy var selectAvatarButtonField = ButtonField(title: "Select Image") { [weak self] _ in
        self?.selectImage()
    }

    lazy var uploadImageButtonField = ButtonField(
        title: "Upload Image",
        isActionButton: true,
        enabled: false
    ) { [weak self] _ in
        self?.uploadImageButtonHandler()
    }

    override var form: [FormField] {
        [
            emailFormField,
            tokenFormField,
            backendSelectionBehaviorButtonField,
            selectAvatarButtonField,
            uploadImageButtonField,
            avatarImageField,
            resultField
        ]
    }

    private let activityIndicator = UIActivityIndicatorView(style: .large)
    private var avatarSelectionBehavior: AvatarSelection = .preserveSelection

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Upload Image"

        tableView.tableFooterView = activityIndicator

        emailFormField.$text
            .map { $0.isEmpty }
            .sink
        { [weak self] isEmpty in
            guard let self else { return }
            uploadImageButtonField.isEnabled = !isEmpty
            update(uploadImageButtonField)
        }
        .store(in: &cancellables)
    }

    func selectImage() {
        let picker = UIImagePickerController()
        picker.allowsEditing = true
        picker.delegate = self
        present(picker, animated: true)
    }

    @objc func uploadImageButtonHandler() {
        let email = emailFormField.text
        let token = tokenFormField.text

        guard
            activityIndicator.isAnimating == false,
            email.isEmpty == false,
            token.isEmpty == false,
            let image = avatarImageField.image
        else {
            return
        }
        
        activityIndicator.startAnimating()
        resultField.subtitle = ""
        update(resultField)
        let service = Gravatar.AvatarService()

        Task {
            do {
                let avatarModel = try await service.upload(
                    image,
                    selectionBehavior: avatarSelectionBehavior,
                    accessToken: token
                )
                resultField.subtitle = "✅ Avatar id \(avatarModel.id)"
            } catch {
                resultField.subtitle = "Error \((error as NSError).code): \(error.localizedDescription)"
            }
            update(resultField)
            activityIndicator.stopAnimating()
        }
    }
}

extension DemoUploadImageViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.editedImage] as? UIImage else { return }

        let squareImage = makeSquare(image)
        avatarImageField.image = squareImage
        update(avatarImageField)

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
        setAvatarSelectionMethod(with: emailFormField.text)
    }

    @objc private func setAvatarSelectionMethod(with email: String) {
        let controller = UIAlertController(title: "Avatar selection behavior:", message: nil, preferredStyle: .actionSheet)


        AvatarSelection.allCases(for: .init(email)).forEach { selectionCase in
            controller.addAction(UIAlertAction(title: selectionCase.description, style: .default) { [weak self] action in
                guard let self else { return }
                avatarSelectionBehavior = selectionCase
                backendSelectionBehaviorButtonField.subtitle = selectionCase.description
                update(backendSelectionBehaviorButtonField)
            })
        }

        controller.addAction(UIAlertAction(title: "Cancel", style: .cancel))

        present(controller, animated: true)
    }
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
