import Combine
import Gravatar
import UIKit

public class ProfileViewController: UIViewController {
    private let viewModel: ProfileViewModel
    private let profileView: UIView & UIContentView
    private var configuration: ProfileViewConfiguration {
        didSet {
            profileView.configuration = configuration
            refresh(paletteType: configuration.palette)
        }
    }

    private var cancellables = Set<AnyCancellable>()
    private var profileIdentifier: ProfileIdentifier?
    public var profileFetchingErrorHandler: ((ProfileServiceError) -> Void)?

    public let scrollView: UIScrollView = {
        let view = UIScrollView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    public init(configuration: ProfileViewConfiguration, viewModel: ProfileViewModel? = nil, profileIdentifier: ProfileIdentifier?) {
        self.viewModel = viewModel ?? ProfileViewModel()
        self.profileView = configuration.makeContentView()
        self.configuration = configuration
        self.profileIdentifier = profileIdentifier
        super.init(nibName: nil, bundle: nil)
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(scrollView)
        scrollView.addSubview(profileView)
        self.profileView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            profileView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            profileView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            profileView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            profileView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            profileView.widthAnchor.constraint(equalTo: view.widthAnchor),
        ])
        receiveViewModelUpdates()
        if let profileIdentifier {
            fetchProfile(profileIdentifier: profileIdentifier)
        }
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func receiveViewModelUpdates() {
        viewModel.$profileFetchingResult.sink { [weak self] result in
            guard let self else { return }
            guard let result else {
                var newConfig = self.configuration
                newConfig.model = nil
                newConfig.summaryModel = nil
                self.configuration = newConfig
                return
            }

            switch result {
            case .success(let profile):
                var newConfig = self.configuration
                newConfig.model = profile
                newConfig.summaryModel = profile
                self.configuration = newConfig
            case .failure(let error):
                self.profileFetchingErrorHandler?(error)
            }
        }.store(in: &cancellables)

        viewModel.$isLoading.sink { [weak self] isLoading in
            guard let self else { return }
            var newConfig = self.configuration
            newConfig.isLoading = isLoading
            self.configuration = newConfig
        }.store(in: &cancellables)
    }

    public func clear() {
        viewModel.clear()
    }

    public func fetchProfile(profileIdentifier: ProfileIdentifier) {
        Task {
            await viewModel.fetchProfile(profileIdentifier: profileIdentifier)
        }
    }

    private func refresh(paletteType: PaletteType) {
        view.backgroundColor = paletteType.palette.background.primary
    }
}
