import Gravatar
import XCTest

final class AvatarIdentifierTests: XCTestCase {
    private let testEmailString = "test@example.com"
    private let testHashString = "testhash123"

    func testAvatarIdentifierFromEmailString() {
        let avatarIdentifier: AvatarIdentifier = .email(testEmailString)

        guard case .email(let email) = avatarIdentifier else {
            XCTFail("AvatarIdentifier should be of type .email")
            return
        }

        XCTAssertEqual(email.rawValue, testEmailString)
    }

    func testAvatarIdentifierFromHashString() {
        let testHash = "testhash123"
        let avatarIdentifier: AvatarIdentifier = .hashID(testHash)

        guard case .hashID(let hashID) = avatarIdentifier else {
            XCTFail("AvatarIdentifier should be of type .hashID")
            return
        }

        XCTAssertEqual(hashID.id, testHash)
    }

    func testAvatarIdentifierIDFromEmailIsHash() {
        let testEmail = Email(testEmailString)
        let testEmailHashID = HashID(email: testEmail)

        let avatarIdentifier: AvatarIdentifier = .email(testEmail)

        XCTAssertEqual(avatarIdentifier.id, testEmailHashID.id)
    }

    func testAvatarIdentifierIDFromHashIDIsHash() {
        let avatarIdentifier: AvatarIdentifier = .hashID(testHashString)

        XCTAssertEqual(avatarIdentifier.id, testHashString)
    }
}
