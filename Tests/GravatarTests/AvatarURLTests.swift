import Gravatar
import XCTest

final class AvatarURLTests: XCTestCase {
    let verifiedAvatarURL = URL(string: "https://0.gravatar.com/avatar/205e460b479e2e5b48aec07710c08d50")!
    let verifiedAvatarURL2 = URL(string: "https://gravatar.com/avatar/205e460b479e2e5b48aec07710c08d50")!

    let exampleEmail = "some@email.com"
    let exampleEmailSHA = "676212ff796c79a3c06261eb10e3f455aa93998ee6e45263da13679c74b1e674"

    func testIsAvatarUrl() throws {
        XCTAssertTrue(AvatarURL.isAvatarUrl(verifiedAvatarURL))
        XCTAssertTrue(AvatarURL.isAvatarUrl(verifiedAvatarURL2))
        XCTAssertFalse(AvatarURL.isAvatarUrl(URL(string: "https://gravatar.com/")!))
        XCTAssertFalse(AvatarURL.isAvatarUrl(URL(string: "https:/")!))
    }

    func testAvatarURLWithDifferentPixelSizes() throws {
        XCTAssertEqual(verifiedAvatarURL(options: AvatarQueryOptions(preferredSize: .pixels(24))).url.query, "s=24")
        XCTAssertEqual(verifiedAvatarURL(options: AvatarQueryOptions(preferredSize: .pixels(128))).url.query, "s=128")
        XCTAssertEqual(verifiedAvatarURL(options: AvatarQueryOptions(preferredSize: .pixels(256))).url.query, "s=256")
        XCTAssertEqual(verifiedAvatarURL(options: AvatarQueryOptions(preferredSize: .pixels(0))).url.query, "s=0")
        XCTAssertEqual(verifiedAvatarURL(options: AvatarQueryOptions(preferredSize: .pixels(-10))).url.query, "s=-10")
    }

    func testAvatarURLWithPointSize() throws {
        let pointSize = CGFloat(200)
        let expectedPixelSize = pointSize * UIScreen.main.scale

        let url = AvatarURL(url: verifiedAvatarURL, options: AvatarQueryOptions(preferredSize: .points(pointSize)))?.url

        XCTAssertNotNil(url)
        XCTAssertEqual(url?.query, "s=\(Int(expectedPixelSize))")
    }

    func testUrlWithDefaultImage() throws {
        XCTAssertEqual(verifiedAvatarURL(options: AvatarQueryOptions(defaultAvatarOption: .status404)).url.query, "d=404")
        XCTAssertEqual(verifiedAvatarURL(options: AvatarQueryOptions(defaultAvatarOption: .mysteryPerson)).url.query, "d=mp")
        XCTAssertEqual(verifiedAvatarURL(options: AvatarQueryOptions(defaultAvatarOption: .monsterId)).url.query, "d=monsterid")
        XCTAssertEqual(verifiedAvatarURL(options: AvatarQueryOptions(defaultAvatarOption: .retro)).url.query, "d=retro")
        XCTAssertEqual(verifiedAvatarURL(options: AvatarQueryOptions(defaultAvatarOption: .roboHash)).url.query, "d=robohash")
        XCTAssertEqual(verifiedAvatarURL(options: AvatarQueryOptions(defaultAvatarOption: .transparentPNG)).url.query, "d=blank")
        XCTAssertEqual(verifiedAvatarURL(options: AvatarQueryOptions(defaultAvatarOption: .wavatar)).url.query, "d=wavatar")
    }

    func testUrlWithForcedImageDefault() throws {
        let avatarUrl = verifiedAvatarURL(options: AvatarQueryOptions())
        XCTAssertEqual(avatarUrl.url.query, nil)
        XCTAssertEqual(verifiedAvatarURL(options: AvatarQueryOptions(forceDefaultAvatar: true)).url.query, "f=y")
    }

    func testUrlWithForceImageDefaultFalse() {
        XCTAssertEqual(verifiedAvatarURL(options: AvatarQueryOptions(forceDefaultAvatar: false)).url.query, "f=n")
    }

    func testCreateAvatarURLWithEmail() throws {
        let avatarUrl = AvatarURL(with: .email(exampleEmail))!
        XCTAssertEqual(
            avatarUrl.url.absoluteString,
            "https://gravatar.com/avatar/676212ff796c79a3c06261eb10e3f455aa93998ee6e45263da13679c74b1e674"
        )

        let urlReplacingDefaultImage = avatarUrl.replacing(options: AvatarQueryOptions(defaultAvatarOption: .identicon))
        XCTAssertEqual(
            urlReplacingDefaultImage?.url.absoluteString,
            "https://gravatar.com/avatar/676212ff796c79a3c06261eb10e3f455aa93998ee6e45263da13679c74b1e674?d=identicon"
        )

        let urlReplacingSize = avatarUrl.replacing(options: AvatarQueryOptions(preferredSize: .pixels(24)))
        XCTAssertEqual(
            urlReplacingSize?.url.absoluteString,
            "https://gravatar.com/avatar/676212ff796c79a3c06261eb10e3f455aa93998ee6e45263da13679c74b1e674?s=24"
        )

        let urlReplacingRating = avatarUrl.replacing(options: AvatarQueryOptions(rating: .parentalGuidance))
        XCTAssertEqual(
            urlReplacingRating?.url.absoluteString,
            "https://gravatar.com/avatar/676212ff796c79a3c06261eb10e3f455aa93998ee6e45263da13679c74b1e674?r=pg"
        )

        let urlReplacingForceDefault = avatarUrl.replacing(options: AvatarQueryOptions(forceDefaultAvatar: true))
        XCTAssertEqual(
            urlReplacingForceDefault?.url.absoluteString,
            "https://gravatar.com/avatar/676212ff796c79a3c06261eb10e3f455aa93998ee6e45263da13679c74b1e674?f=y"
        )

        let allOptions = AvatarQueryOptions(
            preferredSize: .pixels(200),
            rating: .general,
            defaultAvatarOption: .monsterId,
            forceDefaultAvatar: true
        )
        let urlReplacingAllOptions = avatarUrl.replacing(options: allOptions)
        XCTAssertEqual(
            urlReplacingAllOptions?.url.absoluteString,
            "https://gravatar.com/avatar/676212ff796c79a3c06261eb10e3f455aa93998ee6e45263da13679c74b1e674?d=monsterid&s=200&r=g&f=y"
        )
    }

    func testCreateAvatarWithHash() {
        let avatarUrl = AvatarURL(with: .hashID("HASH"))
        XCTAssertEqual(avatarUrl?.url.absoluteString, "https://gravatar.com/avatar/HASH")
    }

    func testCreateAvatarByUpdatingOptions() {
        let avatarUrl = AvatarURL(with: .hashID("HASH"), options: AvatarQueryOptions(defaultAvatarOption: .status404))
        XCTAssertEqual(avatarUrl?.url.absoluteString, "https://gravatar.com/avatar/HASH?d=404")
        let updatedAvatarUrl = avatarUrl?.replacing(options: AvatarQueryOptions(rating: .parentalGuidance))
        XCTAssertEqual(updatedAvatarUrl?.url.absoluteString, "https://gravatar.com/avatar/HASH?r=pg")
    }

    func testCreateAvatarWithHashWithInvalidCharacters() {
        let avatarUrl = AvatarURL(with: .hashID("😉⇶❖₧ℸℏ⎜♘§@…./+_ =-\\][|}{~`23🥡"))
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

    func verifiedAvatarURL(options: AvatarQueryOptions = AvatarQueryOptions()) -> AvatarURL {
        AvatarURL(url: verifiedAvatarURL, options: options)!
    }
}
