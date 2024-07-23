import Gravatar
import XCTest

final class ProfileIdentifierTests: XCTestCase {
    private enum Constants {
        static let email = "test@example.com"
    }

    private let testEmail = Constants.email
    private let testEmailHash = Email(Constants.email).id

    func testProfileIdentifierIDFromEmailStringIsHash() {
        let profileIdentifier: ProfileIdentifier = .email(testEmail)

        XCTAssertEqual(profileIdentifier.id, testEmailHash)
    }

    func testProfileIdentifierIDFromHashStringIsHash() {
        let testHash = "testhash123"

        let profileIdentifier: ProfileIdentifier = .hashID(testHash)

        XCTAssertEqual(profileIdentifier.id, testHash)
    }

    func testProfileIdentifierWithEmailReturnsAvatarIdentifierWithEmail() {
        let profileIdentifier: ProfileIdentifier = .email(testEmail)

        guard case .email(let email) = profileIdentifier.avatarIdentifier else {
            XCTFail("AvatarIdentifer should be of type .email")
            return
        }

        XCTAssertEqual(email.id, testEmailHash)
    }

    func testProfileIdentifierWithHashReturnsAvatarIdentifierWithHash() {
        let profileIdentifier: ProfileIdentifier = .hashID(testEmailHash)

        guard case .hashID(let emailHash) = profileIdentifier.avatarIdentifier else {
            XCTFail("AvatarIdentifer should be of type .hashID")
            return
        }

        XCTAssertEqual(emailHash.id, testEmailHash)
    }
}
