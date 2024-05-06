import GravatarUI
import SnapshotTesting
import XCTest

final class ProfileButtonTests: XCTestCase {
    let frame = CGRect(x: 0, y: 0, width: 100, height: 50)
    let palettesToTest: [PaletteType] = [.light, .dark]

    override func setUp() async throws {
        try await super.setUp()
        // isRecording = true
    }

    @MainActor
    func testProfileButtonViewStyle() {
        let button = UIButton(frame: frame)
        Configure(button)
            .asProfileButton()
            .palette(.light)
            .style(.view)
        XCTAssertEqual(button.titleLabel?.text, "View profile")
    }

    @MainActor
    func testProfileButtonEditStyle() {
        let button = UIButton(frame: frame)
        Configure(button)
            .asProfileButton()
            .palette(.light)
            .style(.edit)
        XCTAssertEqual(button.titleLabel?.text, "Edit profile")
    }

    @MainActor
    func testProfileButtonSnapshots() {
        let button = UIButton(frame: frame)

        for style in [ProfileButtonStyle.view, .edit] {
            Configure(button)
                .asProfileButton()
                .style(style)
                .palette(.light)

            assertSnapshot(of: button, as: .image, named: "\(style)")
        }
    }
}
