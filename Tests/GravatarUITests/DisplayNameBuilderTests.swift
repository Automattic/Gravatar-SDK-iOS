import GravatarUI
import SnapshotTesting
import XCTest

final class DisplayNameBuilderTests: XCTestCase {
    let frame = CGRect(x: 0, y: 0, width: 320, height: 200)
    let frameSmall = CGRect(x: 0, y: 0, width: 100, height: 200)
    let palettesToTest: [PaletteType] = [.light, .dark]

    override func setUp() async throws {
        try await super.setUp()
        // isRecording = true
    }

    func testDisplayNameField() {
        let displayName = TestDisplayName(displayName: "Display Name")
        let label = UILabel(frame: frame)
        for palette in palettesToTest {
            Configure(label)
                .asDisplayName()
                .content(displayName)
                .palette(palette)
            assertSnapshot(of: label, as: .image, named: "testDisplayNameField-\(palette.name)")
        }
    }

    func testDisplayNameFieldWithSmallWidth() {
        let displayName = TestDisplayName(displayName: "Display Name")
        let label = UILabel(frame: frameSmall)
        Configure(label)
            .asDisplayName()
            .content(displayName)
            .palette(.light)
        assertSnapshot(of: label, as: .image)
    }
}

struct TestDisplayName: DisplayNameModel {
    var displayName: String
}
