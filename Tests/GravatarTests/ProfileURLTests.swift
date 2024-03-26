import Gravatar
import XCTest

final class ProfileURLTests: XCTestCase {
    let urlFromEmail = URL(string: "https://gravatar.com/676212ff796c79a3c06261eb10e3f455aa93998ee6e45263da13679c74b1e674")!
    let hashFromEmail = "676212ff796c79a3c06261eb10e3f455aa93998ee6e45263da13679c74b1e674"
    let email = "some@email.com"

    func testProfileUrlWithEmail() {
        let profileUrl = ProfileURL(with: .email(email))
        XCTAssertEqual(profileUrl?.url.absoluteString, urlFromEmail.absoluteString)
    }

    func testProfileUrlHashWithEmail() {
        let profileUrl = ProfileURL(with: .email(email))
        XCTAssertEqual(profileUrl?.hash, hashFromEmail)
    }

    func testProfileUrlWithHash() {
        let profileUrl = ProfileURL(with: .hashID(hashFromEmail))
        XCTAssertEqual(profileUrl?.url.absoluteString, urlFromEmail.absoluteString)
    }

    func testAvatarURLFromProfileUrl() {
        let profileUrl = ProfileURL(with: .email(email))
        XCTAssertEqual(profileUrl?.avatarURL, AvatarURL(with: .email(email)))
    }

    func testProfileUrlWithEmailWithInvalidCharactersWontCrash() {
        let profileUrl = ProfileURL(with: .email("😉⇶❖₧ℸℏ⎜♘§@…./+_ =-\\][|}{~`23🥡"))
        XCTAssertEqual(profileUrl?.hash, "d8bf26df33ebe638f5ad553aedc6df15e67e7e64f3f21e21c03223877a9290c9")
    }

    func testProfileUrlWithHashWithInvalidCharactersWontCrash() {
        let profileUrl = ProfileURL(with: .hashID("😉⇶❖₧ℸℏ⎜♘§@…./+_ =-\\][|}{~`23🥡"))
        XCTAssertEqual(
            profileUrl?.url.absoluteString,
            "https://gravatar.com/%F0%9F%98%89%E2%87%B6%E2%9D%96%E2%82%A7%E2%84%B8%E2%84%8F%E2%8E%9C%E2%99%98%C2%A7@%E2%80%A6./+_%20=-%5C%5D%5B%7C%7D%7B~%6023%F0%9F%A5%A1"
        )
    }
}
