import Gravatar
import GravatarUI
import SnapshotTesting
import XCTest

final class PersonalInfoBuilderTests: XCTestCase {
    let frame = CGRect(x: 0, y: 0, width: 320, height: 200)
    let frameSmall = CGRect(x: 0, y: 0, width: 100, height: 200)
    let palettesToTest: [PaletteType] = [.light, .dark]

    override func setUp() async throws {
        try await super.setUp()
        // isRecording = true
    }

    func testPersonalInfoEmpty() {
        let label = UILabel(frame: frame)
        Configure(label)
            .asPersonalInfo()
            .content(TestPersonalInfo.empty())
        XCTAssertEqual(label.text, "")
    }

    func testPersonalInfoFull() {
        let label = UILabel(frame: frame)
        for palette in palettesToTest {
            Configure(label)
                .asPersonalInfo()
                .content(TestPersonalInfo.fullInfo())
                .palette(palette)
            assertSnapshot(of: label, as: .image, named: "testPersonalInfoFull-\(palette.name)")
        }
    }

    func testPersonalInfoCustom() {
        let label = UILabel(frame: frame)
        for palette in palettesToTest {
            Configure(label)
                .asPersonalInfo()
                .content(TestPersonalInfo.fullInfo(), lines: [
                    .init([.namePronunciation, .separator(" - "), .jobTitle]),
                    .init([.location]),
                ])
                .palette(palette)
            assertSnapshot(of: label, as: .image, named: "testPersonalInfoFull-\(palette.name)")
        }
    }

    func testPersonalInfoWithSmallWidth() {
        let label = UILabel(frame: frameSmall)
        Configure(label)
            .asPersonalInfo()
            .content(TestPersonalInfo.fullInfo())
            .palette(.light)
        assertSnapshot(of: label, as: .image)
    }
}

struct TestPersonalInfo: PersonalInfoModel {
    var jobTitle: String?
    var pronunciation: String?
    var pronouns: String?
    var currentLocation: String?

    static func fullInfo() -> TestPersonalInfo {
        TestPersonalInfo(jobTitle: "Carpenter", pronunciation: "Car-N", pronouns: "she/her", currentLocation: "Connecticut")
    }
    
    static func empty() -> TestPersonalInfo {
        TestPersonalInfo()
    }
}
