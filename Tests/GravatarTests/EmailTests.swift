import Gravatar
import XCTest

final class EmailTests: XCTestCase {
    private let testEmail = "test@example.com"

    func testEmailSanitized() {
        let sanitaryEmailString = "test@example.com"
        let unsanitaryEmailString = " TeST@Example.com "

        let hopefullySantizedEmail: Email = .init(unsanitaryEmailString)

        XCTAssertEqual(hopefullySantizedEmail.rawValue, sanitaryEmailString)
    }

    func testEmailIDIsHashID() {
        let emailHashID: HashID = .init(email: .init(testEmail))

        let email: Email = .init(testEmail)

        XCTAssertEqual(email.id, emailHashID.id)
    }

    func testEmailRawValueIsEmailString() throws {
        let sut: Email = try XCTUnwrap(.init(rawValue: testEmail))

        XCTAssertEqual(sut.rawValue, testEmail)
    }
}
