import GravatarUI
import SnapshotTesting
import XCTest

@MainActor
final class ProfileButtonTests: XCTestCase {
    let frame = CGRect(x: 0, y: 0, width: 100, height: 50)
    let palettesToTest: [PaletteType] = [.light, .dark]

    override func setUp() async throws {
        try await super.setUp()
        // isRecording = true
    }

    func testProfileButtonViewStyle() {
        let button = UIButton(frame: frame)
        Configure(button)
            .asProfileButton()
            .palette(.light)
            .style(.view)
        XCTAssertEqual(button.titleLabel?.text, "View profile")
    }

    func testProfileButtonEditStyle() {
        let button = UIButton(frame: frame)
        Configure(button)
            .asProfileButton()
            .palette(.light)
            .style(.edit)
        XCTAssertEqual(button.titleLabel?.text, "Edit profile")
    }

    func testProfileButtonSnapshots() {
        let button = UIButton(frame: frame)

        [ProfileButtonStyle.view, .edit].forEach {
            Configure(button)
                .asProfileButton()
                .style($0)
                .palette(.light)

            assertSnapshot(of: button, as: .image, named: "\($0)")
        }
    }
}
