import Gravatar
import GravatarUI
import SnapshotTesting
import XCTest

final class ProfileViewTests: XCTestCase {
    enum Constants {
        static let width: CGFloat = 320
    }

    override func setUp() async throws {
        try await super.setUp()
        // isRecording = true
    }

    func testProfileView() throws {
        for interfaceStyle in UIUserInterfaceStyle.allCases {
            let containerView = createViews(model: TestProfileCardModel.summaryCard())
            containerView.overrideUserInterfaceStyle = interfaceStyle
            assertSnapshot(of: containerView, as: .image, named: "\(interfaceStyle.name)")
        }
    }
    
    func testEmptyProfileView() throws {
        for interfaceStyle in UIUserInterfaceStyle.allCases {
            let containerView = createViews(model: nil)
            containerView.overrideUserInterfaceStyle = interfaceStyle
            assertSnapshot(of: containerView, as: .image, named: "\(interfaceStyle.name)")
        }
    }

    private func createViews(model: ProfileModel?) -> UIView {
        let cardView = ProfileView(frame: .zero, paletteType: .system)
        cardView.update(with: model)
        if model != nil {
            cardView.avatarImageView.backgroundColor = .systemBlue
        }
        cardView.translatesAutoresizingMaskIntoConstraints = false
        cardView.widthAnchor.constraint(equalToConstant: Constants.width).isActive = true

        return cardView.wrapInSuperView(with: Constants.width)
    }
}

extension UIView {
    func wrapInSuperView(with width: CGFloat) -> UIView {
        let containerView = UIView()
        containerView.backgroundColor = .secondarySystemBackground
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.widthAnchor.constraint(equalToConstant: width + 20).isActive = true

        containerView.addSubview(self)
        topAnchor.constraint(equalTo: containerView.topAnchor, constant: 10).isActive = true
        bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -10).isActive = true
        centerXAnchor.constraint(equalTo: containerView.centerXAnchor).isActive = true
        return containerView
    }
}

extension UIUserInterfaceStyle {
    var name: String {
        switch self {
        case .light: "light"
        case .dark: "dark"
        default: "unknown"
        }
    }

    static var allCases: [UIUserInterfaceStyle] {
        [.light, .dark]
    }
}
