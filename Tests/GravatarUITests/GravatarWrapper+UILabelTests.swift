import Gravatar
import GravatarUI
import XCTest
import SnapshotTesting

final class GravatarWrapper_UILabelTests: XCTestCase {
    
    let frame = CGRect(x: 0, y: 0, width: 320, height: 200)
    let frameSmall = CGRect(x: 0, y: 0, width: 100, height: 200)

    let palettesToTest: [PaletteType] = [.light, .dark]
    
    override func setUp() async throws {
        try await super.setUp()
        isRecording = true
    }
    
    func testAboutMe() {
        let label = UILabel(frame: frame)
        palettesToTest.forEach { palette in
            label.gravatar.aboutMe.update(with: TestAboutMeModel.new(), paletteType: palette)
            assertSnapshot(of: label, as: .image, named: "testAboutMe-\(palette.name)")
        }
    }
    
    func testAboutMeWithSmallWidth() {
        let label = UILabel(frame: frameSmall)
        label.gravatar.aboutMe.update(with: TestAboutMeModel.new(), paletteType: .light)
        assertSnapshot(of: label, as: .image)
    }
    
    func testPersonalInfoFull() {
        let label = UILabel(frame: frame)
        palettesToTest.forEach { palette in
            label.gravatar.personalInfo.update(with: TestPersonalInfo.fullInfo(), paletteType: palette)
            assertSnapshot(of: label, as: .image, named: "testPersonalInfoFull-\(palette.name)")
        }
    }
    
    func testPersonalInfoCustom() {
        let label = UILabel(frame: frame)
        palettesToTest.forEach { palette in
            label.gravatar.personalInfo.update(with: TestPersonalInfo.fullInfo(), 
                                               lines: [
                                                .init([.namePronunciation, .separator(" - "), .jobTitle]),
                                                    .init([.location])
                                               ], paletteType: palette)
            assertSnapshot(of: label, as: .image, named: "testPersonalInfoFull-\(palette.name)")
        }
    }
    
    func testPersonalInfoWithSmallWidth() {
        let label = UILabel(frame: frameSmall)
        label.gravatar.personalInfo.update(with: TestPersonalInfo.fullInfo(), paletteType: .light)
        assertSnapshot(of: label, as: .image)
    }

    func testDisplayNameField() {
        let displayName = TestDisplayName(displayName: "Display Name", fullName: "Name Surname", userName: "username")
        let label = UILabel(frame: frame)
        palettesToTest.forEach { palette in
            label.gravatar.displayName.update(with: displayName, paletteType: palette)
            assertSnapshot(of: label, as: .image, named: "testDisplayNameField-\(palette.name)")
        }
    }
    
    func testDisplayNameFieldWithSmallWidth() {
        let displayName = TestDisplayName(displayName: "Display Name", fullName: "Name Surname", userName: "username")
        let label = UILabel(frame: frameSmall)
        label.gravatar.displayName.update(with: displayName, paletteType: .light)
        assertSnapshot(of: label, as: .image)
    }
    
    func testDisplayNameFieldWithMissingNames() {
        let displayName = TestDisplayName(displayName: nil, fullName: nil, userName: "username")
        let label = UILabel(frame: frame)
        palettesToTest.forEach { palette in
            label.gravatar.displayName.update(with: displayName, paletteType: palette)
            assertSnapshot(of: label, as: .image, named: "testDisplayNameFieldWithMissingNames-\(palette.name)")
        }
    }
    
    func testDisplayNameFieldWithMissingDisplayName() {
        let displayName = TestDisplayName(displayName: nil, fullName: "Name Surname", userName: "username")
        let label = UILabel(frame: frame)
        palettesToTest.forEach { palette in
            label.gravatar.displayName.update(with: displayName, paletteType: palette)
            assertSnapshot(of: label, as: .image, named: "testDisplayNameFieldWithMissingDisplayName-\(palette.name)")
        }
    }
}

struct TestAboutMeModel: AboutMeModel {
    var aboutMe: String?
    static func new() -> TestAboutMeModel {
        TestAboutMeModel(aboutMe: "Hi, I am 20 years old. My favorite fruit is sour cherry. My favorite pet is racoon.")
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
}

struct TestDisplayName: DisplayNameModel {
    var displayName: String?
    var fullName: String?
    var userName: String
}
