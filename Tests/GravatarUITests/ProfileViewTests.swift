import Gravatar
import GravatarUI
import SnapshotTesting
import XCTest

final class ProfileViewTests: XCTestCase {
    enum Constants {
        static let width: CGFloat = 320
        static let containerHeight: CGFloat = 350
    }

    let palettesToTest: [UIUserInterfaceStyle] = [.light, .dark]

    override func setUp() async throws {
        try await super.setUp()
        //isRecording = true
    }

    func testProfileView() throws {
        for interfaceStyle in palettesToTest {
            let containerView = createViews(model: TestProfileCardModel.summaryCard())
            containerView.overrideUserInterfaceStyle = interfaceStyle
            assertSnapshot(of: containerView, as: .image, named: "\(interfaceStyle.name)")
        }
    }

    private func createViews(model: ProfileCardModel) -> UIView {
        let cardView = ProfileView(frame: .zero, paletteType: .system)
        cardView.avatarImageView.backgroundColor = .systemBlue
        cardView.update(with: model)
        cardView.translatesAutoresizingMaskIntoConstraints = false
        cardView.widthAnchor.constraint(equalToConstant: Constants.width).isActive = true

        let containerView = UIView()
        containerView.backgroundColor = .secondarySystemBackground
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.widthAnchor.constraint(equalToConstant: Constants.width + 20).isActive = true

        containerView.addSubview(cardView)
        cardView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 10).isActive = true
        cardView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -10).isActive = true
        cardView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor).isActive = true

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
}
