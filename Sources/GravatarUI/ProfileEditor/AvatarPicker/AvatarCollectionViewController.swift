import UIKit

class AvatarCollectionViewController: UICollectionViewController {
    private enum Section {
        case main
    }

    private var avatarImageModels: [String: AvatarImageModel] = [:]

    private var snapshot = NSDiffableDataSourceSnapshot<Section, String>()

    private lazy var dataSource: UICollectionViewDiffableDataSource<Section, String> = {
        let cellRegistration = UICollectionView.CellRegistration<AvatarCollectionViewCell, String>() { cell, _, avatarID in
            let avatarModel = self.avatarImageModels[avatarID]

            switch avatarModel?.state {
            case .remote(let url, let isLoading):
                cell.isLoading = isLoading
                Task {
                    try? await cell.imageView.gravatar.setImage(
                        with: avatarModel?.url,
                        placeholder: UIImage(systemName: "person.circle.fill")
                    )
                }
            case .local(let image):
                cell.imageView.image = image
                cell.isLoading = true
                return
            case .none: break
            }
        }

        return .init(collectionView: collectionView) { (collectionView: UICollectionView, indexPath: IndexPath, item: String) in
            collectionView.dequeueConfiguredReusableCell(
                using: cellRegistration,
                for: indexPath,
                item: item
            )
        }
    }()

    init() {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = .init(width: 90, height: 90)
        layout.minimumInteritemSpacing = 40
        super.init(collectionViewLayout: layout)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        snapshot.appendSections([.main])
        dataSource.apply(snapshot)
    }

    // MARK: - Data source

    func append(_ avatars: [AvatarImageModel]) async {
        avatars.forEach {
            avatarImageModels[$0.id] = $0
        }

        let ids = avatars.map { $0.id }
        for avatarID in ids {
            if !snapshot.itemIdentifiers.contains(where: { $0 == avatarID }) {
                snapshot.appendItems([avatarID])
            }
        }

        await dataSource.apply(snapshot, animatingDifferences: true)
    }

    func append(_ avatars: [AvatarImageModel]) {
        Task { 
            await append(avatars)
        }
    }

    func remove(_ avatarModel: AvatarImageModel) {
        snapshot.deleteItems([avatarModel.id])
        dataSource.apply(snapshot)
    }

    func indexPath(for avatar: AvatarImageModel) -> IndexPath? {
        dataSource.indexPath(for: avatar.id)
    }

    func item(with id: String) -> AvatarImageModel? {
        return avatarImageModels[id]
    }

    func item(with indexPath: IndexPath) -> AvatarImageModel? {
        guard let id = dataSource.itemIdentifier(for: indexPath) else {
            return nil
        }
        return avatarImageModels[id]
    }

    func refresItem(with avatar: AvatarImageModel) {
        avatarImageModels[avatar.id] = avatar
        snapshot.reloadItems([avatar.id])
        dataSource.apply(snapshot)
    }
}
