import Gravatar
@testable import GravatarUI
import SnapshotTesting
import XCTest

final class TestPlaceholderDisplayers: XCTestCase {
    enum Constants {
        static let elementSize = CGSize(width: 40, height: 20)
        static let containerWidth = elementSize.width * 2
    }

    override func setUpWithError() throws {
        try super.setUpWithError()
        // isRecording = true
    }

    @MainActor
    func testBackgroundColorPlaceholderDisplayer() throws {
        let view = UIView(frame: .zero)
        view.applySize(Constants.elementSize)
        let containerView = view.wrapInSuperView(with: Constants.containerWidth)
        let placeholderDisplayer = BackgroundColorPlaceholderDisplayer(
            baseView: view,
            color: .porpoiseGray,
            originalBackgroundColor: .white
        )
        placeholderDisplayer.showPlaceholder()
        assertSnapshot(of: containerView, as: .image, named: "placeholder-shown")
        placeholderDisplayer.hidePlaceholder()
        assertSnapshot(of: containerView, as: .image, named: "placeholder-hidden")
    }

    @MainActor
    func testBackgroundColorPlaceholderDisplayerTemporaryField() throws {
        let view = UIView(frame: .zero)
        view.isHidden = true
        view.applySize(Constants.elementSize)
        let placeholderDisplayer = BackgroundColorPlaceholderDisplayer(
            baseView: view,
            color: .porpoiseGray,
            originalBackgroundColor: .white,
            isTemporary: true
        )
        placeholderDisplayer.showPlaceholder()
        XCTAssertFalse(view.isHidden)
        placeholderDisplayer.hidePlaceholder()
        XCTAssertTrue(view.isHidden)
    }

    @MainActor
    func testRectangularColorPlaceholderDisplayer() throws {
        let view = UIView(frame: .zero)
        view.applySize(Constants.elementSize)
        let containerView = view.wrapInSuperView(with: Constants.containerWidth)
        let placeholderDisplayer = RectangularPlaceholderDisplayer(
            baseView: view,
            color: .porpoiseGray,
            originalBackgroundColor: .white,
            cornerRadius: 8,
            height: Constants.elementSize.height,
            widthRatioToParent: 0.8
        )
        placeholderDisplayer.showPlaceholder()
        assertSnapshot(of: containerView, as: .image, named: "placeholder-shown")
        placeholderDisplayer.hidePlaceholder()
        assertSnapshot(of: containerView, as: .image, named: "placeholder-hidden")
    }

    @MainActor
    func testProfileButtonPlaceholderDisplayer() throws {
        let button = UIButton(frame: .zero)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("View profile", for: .normal)
        button.setImage(UIImage(systemName: "star.fill"), for: .normal)
        let containerView = button.wrapInSuperView(with: 120)
        let placeholderDisplayer = ProfileButtonPlaceholderDisplayer(
            baseView: button,
            color: .porpoiseGray,
            originalBackgroundColor: .dugongGray,
            cornerRadius: 8,
            height: 30,
            widthRatioToParent: 0.8
        )
        placeholderDisplayer.showPlaceholder()
        assertSnapshot(of: containerView, as: .image, named: "placeholder-shown")
        placeholderDisplayer.hidePlaceholder()
        assertSnapshot(of: containerView, as: .image, named: "placeholder-hidden")
    }

    @MainActor
    func testAccountButtonsPlaceholderDisplayer() throws {
        let stackView = UIStackView(frame: .zero)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.spacing = 4
        let placeholderDisplayer = AccountButtonsPlaceholderDisplayer(containerStackView: stackView, color: .porpoiseGray)
        placeholderDisplayer.showPlaceholder()
        assertSnapshot(of: stackView, as: .image, named: "placeholder-shown")
        placeholderDisplayer.hidePlaceholder()
        XCTAssertEqual(stackView.frame.size, .zero)
    }
}
