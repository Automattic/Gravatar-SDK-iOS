import Gravatar
import XCTest

final class AvatarURLTests: XCTestCase {
    let verifiedAvatarURL = URL(string: "https://0.gravatar.com/avatar/205e460b479e2e5b48aec07710c08d50")!
    let verifiedAvatarURL2 = URL(string: "https://gravatar.com/avatar/205e460b479e2e5b48aec07710c08d50")!

    let exampleEmail = "some@email.com"
    let exampleEmailSHA = "676212ff796c79a3c06261eb10e3f455aa93998ee6e45263da13679c74b1e674"

    func testisAvatarUrl() throws {
        XCTAssertTrue(AvatarURL.isAvatarUrl(verifiedAvatarURL))
        XCTAssertTrue(AvatarURL.isAvatarUrl(verifiedAvatarURL2))
        XCTAssertFalse(AvatarURL.isAvatarUrl(URL(string: "https://wordpress.com/")!))
    }

    func testAvatarURLWithDifferentPixelSizes() throws {
        XCTAssertEqual(verifiedAvatarURL(options: ImageQueryOptions(preferredSize: .pixels(24)))?.url.query, "s=24")
        XCTAssertEqual(verifiedAvatarURL(options: ImageQueryOptions(preferredSize: .pixels(128)))?.url.query, "s=128")
        XCTAssertEqual(verifiedAvatarURL(options: ImageQueryOptions(preferredSize: .pixels(256)))?.url.query, "s=256")
        XCTAssertEqual(verifiedAvatarURL(options: ImageQueryOptions(preferredSize: .pixels(0)))?.url.query, "s=0")
        XCTAssertEqual(verifiedAvatarURL(options: ImageQueryOptions(preferredSize: .pixels(-10)))?.url.query, "s=-10")
    }

    func testAvatarURLWithPointSize() throws {
        let pointSize = CGFloat(200)
        let expectedPixelSize = pointSize * UIScreen.main.scale

        let url = AvatarURL(url: verifiedAvatarURL, options: ImageQueryOptions(preferredSize: .points(pointSize)))?.url

        XCTAssertNotNil(url)
        XCTAssertEqual(url?.query, "s=\(Int(expectedPixelSize))")
    }

    func testUrlWithDefaultImage() throws {
        XCTAssertEqual(verifiedAvatarURL(options:  ImageQueryOptions(defaultImageOption: .fileNotFound))?.url.query, "d=404")
        XCTAssertEqual(verifiedAvatarURL(options:  ImageQueryOptions(defaultImageOption: .misteryPerson))?.url.query, "d=mp")
        XCTAssertEqual(verifiedAvatarURL(options:  ImageQueryOptions(defaultImageOption: .monsterId))?.url.query, "d=monsterid")
        XCTAssertEqual(verifiedAvatarURL(options:  ImageQueryOptions(defaultImageOption: .retro))?.url.query, "d=retro")
        XCTAssertEqual(verifiedAvatarURL(options:  ImageQueryOptions(defaultImageOption: .roboHash))?.url.query, "d=robohash")
        XCTAssertEqual(verifiedAvatarURL(options:  ImageQueryOptions(defaultImageOption: .transparentPNG))?.url.query, "d=blank")
        XCTAssertEqual(verifiedAvatarURL(options:  ImageQueryOptions(defaultImageOption: .wavatar))?.url.query, "d=wavatar")
    }

    func testUrlWithForcedImageDefault() throws {
        let avatarUrl = verifiedAvatarURL(options: ImageQueryOptions())
        XCTAssertNotNil(avatarUrl)
        XCTAssertEqual(avatarUrl?.url.query, nil)
        XCTAssertEqual(verifiedAvatarURL(options: ImageQueryOptions(forceDefaultImage: true))?.url.query, "f=y")
    }

    func testUrlWithForceImageDefaultFalse() {
        XCTAssertEqual(verifiedAvatarURL(options:  ImageQueryOptions(forceDefaultImage: false))?.url.query, "f=n")
    }

    func testCreateAvatarURLWithEmail() throws {
        let avatarUrl = AvatarURL(email: exampleEmail, options: ImageQueryOptions())
        XCTAssertEqual(
            avatarUrl?.url.absoluteString,
            "https://gravatar.com/avatar/676212ff796c79a3c06261eb10e3f455aa93998ee6e45263da13679c74b1e674"
        )

        let urlAddingDefaultImage = AvatarURL(email: exampleEmail, options: ImageQueryOptions(defaultImageOption: .identicon))
        XCTAssertEqual(
            urlAddingDefaultImage?.url.absoluteString,
            "https://gravatar.com/avatar/676212ff796c79a3c06261eb10e3f455aa93998ee6e45263da13679c74b1e674?d=identicon"
        )

        let urlAddingSize = AvatarURL(email: exampleEmail, options: ImageQueryOptions(preferredSize: .pixels(24)))
        XCTAssertEqual(
            urlAddingSize?.url.absoluteString,
            "https://gravatar.com/avatar/676212ff796c79a3c06261eb10e3f455aa93998ee6e45263da13679c74b1e674?s=24"
        )

        let urlAddingRating = AvatarURL(email: exampleEmail, options:  ImageQueryOptions(rating: .parentalGuidance))
        XCTAssertEqual(
            urlAddingRating?.url.absoluteString,
            "https://gravatar.com/avatar/676212ff796c79a3c06261eb10e3f455aa93998ee6e45263da13679c74b1e674?r=pg"
        )

        let urlAddingForceDefault = AvatarURL(email: exampleEmail, options: ImageQueryOptions(forceDefaultImage: true))
        XCTAssertEqual(
            urlAddingForceDefault?.url.absoluteString,
            "https://gravatar.com/avatar/676212ff796c79a3c06261eb10e3f455aa93998ee6e45263da13679c74b1e674?f=y"
        )

        let allOptions = ImageQueryOptions(
            preferredSize: .pixels(200),
            rating: .general,
            defaultImageOption: .monsterId,
            forceDefaultImage: true
        )
        let urlAddingAllOptions = AvatarURL(email:  exampleEmail, options: allOptions)
        XCTAssertEqual(
            urlAddingAllOptions?.url.absoluteString,
            "https://gravatar.com/avatar/676212ff796c79a3c06261eb10e3f455aa93998ee6e45263da13679c74b1e674?d=monsterid&s=200&r=g&f=y"
        )
    }

    func testCreateAvatarWithHash() {
        let avatarUrl = AvatarURL(hash: "HASH")
        XCTAssertEqual(avatarUrl?.url.absoluteString, "https://gravatar.com/avatar/HASH")
    }

    func testCreateAvatarByUpdatingOptions() {
        let avatarUrl = AvatarURL(hash: "HASH", options: ImageQueryOptions(defaultImageOption: .fileNotFound))
        XCTAssertEqual(avatarUrl?.url.absoluteString, "https://gravatar.com/avatar/HASH?d=404")
        let updatedAvatarUrl = avatarUrl?.updating(options: ImageQueryOptions(rating: .parentalGuidance))
        XCTAssertEqual(updatedAvatarUrl?.url.absoluteString, "https://gravatar.com/avatar/HASH?r=pg")
    }

    func testCreateAvatarWithHashWithInvalidCharacters() {
        let avatarUrl = AvatarURL(hash: "😉⇶❖₧ℸℏ⎜♘§@…./+_ =-\\][|}{~`23🥡")
        XCTAssertEqual(
            avatarUrl?.url.absoluteString,
            "https://gravatar.com/avatar/%F0%9F%98%89%E2%87%B6%E2%9D%96%E2%82%A7%E2%84%B8%E2%84%8F%E2%8E%9C%E2%99%98%C2%A7@%E2%80%A6./+_%20=-%5C%5D%5B%7C%7D%7B~%6023%F0%9F%A5%A1"
        )
    }

    func testIsValidURL() {
        XCTAssertTrue(AvatarURL.isAvatarUrl(verifiedAvatarURL))
        XCTAssertFalse(AvatarURL.isAvatarUrl(URL(string: "http://gravatar.com/")))
        XCTAssertEqual(
            avatarUrl?.url.absoluteString,
            "https://gravatar.com/avatar/%F0%9F%98%89%E2%87%B6%E2%9D%96%E2%82%A7%E2%84%B8%E2%84%8F%E2%8E%9C%E2%99%98%C2%A7@%E2%80%A6./+_%20=-%5C%5D%5B%7C%7D%7B~%6023%F0%9F%A5%A1"
        )
    }

    func testAvatarURLIsEquatable() throws {
        let lhs = AvatarURL(url: verifiedAvatarURL)
        let rhs = AvatarURL(url: verifiedAvatarURL)

        XCTAssertEqual(lhs, rhs)
    }

    func testAvatarURLIsEquatableFails() throws {
        let lhs = AvatarURL(url: URL(string: "https://www.gravatar.com/avatar/000")!)
        let rhs = AvatarURL(url: verifiedAvatarURL)

        XCTAssertNotEqual(lhs, rhs)
    }

    func verifiedAvatarURL(options: ImageQueryOptions) -> AvatarURL? {
        AvatarURL(url: verifiedAvatarURL, options: options)
    }
}
