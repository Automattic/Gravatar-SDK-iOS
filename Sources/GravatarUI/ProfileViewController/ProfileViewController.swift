import Combine
import Gravatar
import UIKit

@MainActor
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
    public var profileFetchingErrorHandler: ((ProfileServiceError) -> Void)?

    let scrollView: UIScrollView = {
        let view = UIScrollView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    public init(configuration: ProfileViewConfiguration, viewModel: ProfileViewModel? = nil) {
        self.viewModel = viewModel ?? ProfileViewModel()
        self.profileView = configuration.makeContentView()
        self.configuration = configuration
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

    private func fetchProfile() {
        Task {
            await viewModel.fetchProfile()
        }
    }
    
    private func refresh(paletteType: PaletteType) {
        view.backgroundColor = paletteType.palette.background.primary
    }
}
