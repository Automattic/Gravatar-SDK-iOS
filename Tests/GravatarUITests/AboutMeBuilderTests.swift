import GravatarUI
import SnapshotTesting
import XCTest

final class AboutMeBuilderTests: XCTestCase {
    let frame = CGRect(x: 0, y: 0, width: 320, height: 200)
    let frameSmall = CGRect(x: 0, y: 0, width: 100, height: 200)
    let palettesToTest: [PaletteType] = [.light, .dark]

    override func setUp() async throws {
        try await super.setUp()
        // isRecording = true
    }

    func testAboutMe() {
        let label = UILabel(frame: frame)
        for palette in palettesToTest {
            Configure(label)
                .asAboutMe()
                .content(TestAboutMeModel.new())
                .palette(palette)
            assertSnapshot(of: label, as: .image, named: "testAboutMe-\(palette.name)")
        }
    }

    func testAboutMeWithSmallWidth() {
        let label = UILabel(frame: frameSmall)
        Configure(label)
            .asAboutMe()
            .content(TestAboutMeModel.new())
            .palette(.light)
        assertSnapshot(of: label, as: .image)
    }
}

struct TestAboutMeModel: AboutMeModel {
    var description: String

    static func new() -> TestAboutMeModel {
        TestAboutMeModel(description: "Hi, I am 20 years old. My favorite fruit is sour cherry. My favorite pet is racoon.")
    }
}
