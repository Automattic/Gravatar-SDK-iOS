import Combine
import Gravatar
import UIKit

@MainActor
public class ProfileViewController: UIViewController {
    let viewModel = ProfileViewModel()
    let profileView: UIView & UIContentView
    public var profileIdentifier: ProfileIdentifier? = nil
    var configuration: ProfileViewConfiguration {
        didSet {
            profileView.configuration = configuration
        }
    }

    private var cancellables = Set<AnyCancellable>()
    var profileFetchingErrorHandler: ((ProfileServiceError) -> Void)?

    public init(configuration: ProfileViewConfiguration, profileIdentifier: ProfileIdentifier? = nil) {
        self.profileView = configuration.makeContentView()
        self.configuration = configuration
        self.profileIdentifier = profileIdentifier
        super.init(nibName: nil, bundle: nil)
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(profileView)
        NSLayoutConstraint.activate([
            view.leadingAnchor.constraint(equalTo: profileView.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: profileView.trailingAnchor),
            view.topAnchor.constraint(equalTo: profileView.topAnchor),
            view.bottomAnchor.constraint(equalTo: profileView.bottomAnchor),
        ])
        receiveViewModelUpdates()
        fetchProfile()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func receiveViewModelUpdates() {
        viewModel.$userProfile.sink { [weak self] profile in
            guard let self else { return }
            var newConfig = self.configuration
            newConfig.model = profile
            newConfig.summaryModel = profile
            self.configuration = newConfig
        }.store(in: &cancellables)

        viewModel.$profileFetchingError.compactMap { $0 }.sink { [weak self] error in
            guard let self else { return }
            var newConfig = self.configuration
            newConfig.model = nil
            newConfig.summaryModel = nil
            self.configuration = newConfig
            self.profileFetchingErrorHandler?(error)
        }.store(in: &cancellables)

        viewModel.$isLoading.sink { [weak self] isLoading in
            guard let self else { return }
            var newConfig = self.configuration
            newConfig.isLoading = isLoading
            self.configuration = newConfig
        }.store(in: &cancellables)
    }

    public func fetchProfile() {
        guard let profileIdentifier else { return }
        Task {
            await viewModel.fetch(with: profileIdentifier)
        }
    }
}
