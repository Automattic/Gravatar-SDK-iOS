import UIKit

class AvatarPickerViewController: UIViewController {
    private enum Section {
        case main
    }

    let email: Email
    let authToken: String

    var selectedImageID: String = "" {
        didSet {
            selectImage(with: selectedImageID)
        }
    }

    let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        // TODO: Localization
        label.text = "Avatars"
        label.font = UIFont.DS.largeTitle
        return label
    }()

    let detailLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = true
        // TODO: Localization
        label.text = "Upload or create your favorite avatar images and connect them to your email address."
        label.font = UIFont.DS.footnote
        label.numberOfLines = 0
        return label
    }()

    lazy var headerStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [
            titleLabel,
            detailLabel,
        ])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 8
        return stack
    }()

    var collectionView: UICollectionView {
        collectionViewController.collectionView
    }

    lazy var collectionViewController: AvatarCollectionViewController = {
        let avatarsViewController = AvatarCollectionViewController()
        addChild(avatarsViewController)
        avatarsViewController.didMove(toParent: self)
        return avatarsViewController
    }()

    lazy var actionButton: UIButton = {
        let button = UIButton(primaryAction: UIAction { [weak self] _ in
            self?.onActionButtonPressed()
        })
        button.translatesAutoresizingMaskIntoConstraints = false
        var config = UIButton.Configuration.filled()
        config.cornerStyle = .capsule
        // TODO: Localization
        config.title = "Upload Image"
        button.configuration = config
        button.heightAnchor.constraint(greaterThanOrEqualToConstant: 50).isActive = true
        return button
    }()

    lazy var rootStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [
            headerStackView,
            collectionView,
            actionButton,
        ])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 14
        return stack
    }()

    public init(email: Email, authToken: String) {
        self.authToken = authToken
        self.email = email
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        collectionView.backgroundColor = .systemBackground
        collectionView.delegate = self

        view.addSubview(rootStackView)
        NSLayoutConstraint.activate([
            rootStackView.leadingAnchor.constraint(equalTo: view.readableContentGuide.leadingAnchor),
            rootStackView.trailingAnchor.constraint(equalTo: view.readableContentGuide.trailingAnchor),
            rootStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            rootStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])

        Task {
            await fetchAvatars()
        }
        Task {
            await fetchIdentity()
        }
    }

    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    func selectImage(with imageID: String) {
        guard
            let imageModel = collectionViewController.item(with: imageID),
            let indexPath = collectionViewController.indexPath(for: imageModel)
        else { return }
        collectionView.selectItem(at: indexPath, animated: true, scrollPosition: .centeredVertically)
    }

    func onActionButtonPressed() {
        let picker = UIImagePickerController()
        picker.allowsEditing = true
        picker.delegate = self
        present(picker, animated: true)
    }

    func presentAvatarUpdatedToast() {
        // TODO: Localization
        presentToast(title: "Avatar updated! May take a few minutes to appear everywhere.")
    }

    private func presentToast(title: String) {
        let toast = ToastViewController(title: title)
        present(toast, animated: true)
    }
}

// MARK: - Networking

extension AvatarPickerViewController {
    func fetchAvatars() async {
        do {
            let images = try await ProfileService().fetchAvatars(with: authToken)
            let models = images.map { AvatarImageModel(id: $0.id, source: .remote(url: $0.url)) }
            await collectionViewController.append(models)
            selectImage(with: selectedImageID)
        } catch {
            print("Error: \(error)")
        }
    }

    func fetchIdentity() async {
        do {
            let identity = try await ProfileService().fetchIdentity(token: authToken, profileID: .email(email))
            selectedImageID = identity.imageId
        } catch {
            print("Error: \(error)")
        }
    }

    func selectAvatar(_ model: AvatarImageModel) async {
        do {
            let loadingModel = model.togglingLoading()
            collectionViewController.refresItem(with: loadingModel)
            let identity = try await ProfileService().selectAvatar(token: authToken, profileID: .email(email), avatarID: model.id)
            collectionViewController.refresItem(with: model)
            selectedImageID = identity.imageId
            presentAvatarUpdatedToast()
        } catch {
            print("Error: \(error)")
        }
    }

    func uploadImage(_ image: UIImage) async {
        let imageService = AvatarService()
        do {
            try await imageService.upload(image, email: email, accessToken: authToken)
            presentAvatarUpdatedToast()
        } catch {
            print("Error: \(error)")
        }
    }
}

extension AvatarPickerViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        guard let selectedModel = collectionViewController.item(with: indexPath) else { return false }

        if selectedImageID == selectedModel.id {
            return false
        }

        if case .remote = selectedModel.source {
            return !selectedModel.isLoading
        }

        return false
    }

    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let selectedModel = collectionViewController.item(with: indexPath) else { return }
        Task {
            await selectAvatar(selectedModel)
        }
    }
}

extension AvatarPickerViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        guard let image = info[.editedImage] as? UIImage else { return }
        dismiss(animated: true)
        Task {
            let temporaryID = UUID().uuidString
            let avatarModel = AvatarImageModel(id: temporaryID, source: .local(image: image), isLoading: true)
            await collectionViewController.append([avatarModel])
            guard let indexPath = collectionViewController.indexPath(for: avatarModel) else { return }
            collectionView.selectItem(at: indexPath, animated: true, scrollPosition: .centeredVertically)
            await uploadImage(image)
            let notLoadingModel = avatarModel.togglingLoading()
            collectionViewController.refresItem(with: notLoadingModel)
        }
    }
}
