import Gravatar
import XCTest

final class HashIDTests: XCTestCase {
    func testInitWithHashString() {
        let hash = "testhash123"

        let sut: HashID = .init(hash)

        XCTAssertEqual(sut.id, hash)
    }

    func testInitWithEmail() {
        let testEmail = "test@example.com"
        let email: Email = .init(testEmail)

        let sut: HashID = .init(email: email)

        XCTAssertEqual(sut.id, email.id)
    }

    func testUnSanitizedEmailProducesNoramlizedHashID() {
        let sanitizedEmail: Email = .init("test@example.com")
        let unSanitizedEmail: Email = .init(" TeST@ExAmPle.com ")

        let hashSanitizedEmail: HashID = .init(email: sanitizedEmail)
        let hashUnSanitizedEmail: HashID = .init(email: unSanitizedEmail)

        XCTAssertEqual(hashSanitizedEmail, hashUnSanitizedEmail)
    }
}
