import UIKit

class AvatarCollectionViewController: UICollectionViewController {
    private enum Section {
        case main
    }

    private var avatarImageModels: [AvatarImageModel] = []

    private var snapshot = NSDiffableDataSourceSnapshot<Section, AvatarImageModel>()

    private lazy var dataSource: UICollectionViewDiffableDataSource<Section, AvatarImageModel> = {
        let cellRegistration = UICollectionView.CellRegistration<AvatarCollectionViewCell, AvatarImageModel>() { cell, _, avatarModel in
            switch avatarModel.state {
            case .remote(let url):
                cell.isLoading = false
                Task {
                    try? await cell.imageView.gravatar.setImage(
                        with: avatarModel.url,
                        placeholder: UIImage(systemName: "person.circle.fill")
                    )
                }
            case .local(let image):
                cell.imageView.image = image
                cell.isLoading = true
                return
            }
        }

        return .init(collectionView: collectionView) { (collectionView: UICollectionView, indexPath: IndexPath, item: AvatarImageModel) in
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
        for avatar in avatars {
            if !snapshot.itemIdentifiers.contains(where: { item in item.id == avatar.id }) {
                snapshot.appendItems([avatar])
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
        snapshot.deleteItems([avatarModel])
        dataSource.apply(snapshot)
    }

    func indexPath(for avatar: AvatarImageModel) -> IndexPath? {
        dataSource.indexPath(for: avatar)
    }
}
