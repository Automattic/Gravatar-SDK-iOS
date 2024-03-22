@testable import Gravatar
import XCTest

final class GravatarURLTests: XCTestCase {
    let verifiedGravatarURL = URL(string: "https://0.gravatar.com/avatar/205e460b479e2e5b48aec07710c08d50")!
    let verifiedGravatarURL2 = URL(string: "https://gravatar.com/avatar/205e460b479e2e5b48aec07710c08d50")!

    let exampleEmail = "some@email.com"
    let exampleEmailSHA = "676212ff796c79a3c06261eb10e3f455aa93998ee6e45263da13679c74b1e674"

    func testIsGravatarUrl() throws {
        XCTAssertTrue(GravatarURL.isGravatarURL(verifiedGravatarURL))
        XCTAssertTrue(GravatarURL.isGravatarURL(verifiedGravatarURL2))
        XCTAssertFalse(GravatarURL.isGravatarURL(URL(string: "https://wordpress.com/")!))
    }

    func testGravatarURLWithDifferentPixelSizes() throws {
        let url = GravatarURL(verifiedGravatarURL)
        XCTAssertNotNil(url)
        XCTAssertEqual(url?.url(with: ImageQueryOptions(preferredSize: .pixels(24))).query, "s=24")
        XCTAssertEqual(url?.url(with: ImageQueryOptions(preferredSize: .pixels(128))).query, "s=128")
        XCTAssertEqual(url?.url(with: ImageQueryOptions(preferredSize: .pixels(256))).query, "s=256")
        XCTAssertEqual(url?.url(with: ImageQueryOptions(preferredSize: .pixels(0))).query, "s=0")
        XCTAssertEqual(url?.url(with: ImageQueryOptions(preferredSize: .pixels(-10))).query, "s=-10")
    }

    func testGravatarUrlWithPointSize() throws {
        let gavatarUrl = GravatarURL(verifiedGravatarURL)
        let pointSize = CGFloat(200)
        let expectedPixelSize = pointSize * UIScreen.main.scale

        let url = gavatarUrl?.url(with: ImageQueryOptions(preferredSize: .points(pointSize)))

        XCTAssertNotNil(url)
        XCTAssertEqual(url?.query, "s=\(Int(expectedPixelSize))")
    }

    func testUrlWithDefaultImage() throws {
        let url = GravatarURL(verifiedGravatarURL)
        XCTAssertNotNil(url)
        XCTAssertEqual(url?.url(with: ImageQueryOptions(defaultAvatarOption: .status404)).query, "d=404")
        XCTAssertEqual(url?.url(with: ImageQueryOptions(defaultAvatarOption: .mysteryPerson)).query, "d=mp")
        XCTAssertEqual(url?.url(with: ImageQueryOptions(defaultAvatarOption: .monsterId)).query, "d=monsterid")
        XCTAssertEqual(url?.url(with: ImageQueryOptions(defaultAvatarOption: .retro)).query, "d=retro")
        XCTAssertEqual(url?.url(with: ImageQueryOptions(defaultAvatarOption: .roboHash)).query, "d=robohash")
        XCTAssertEqual(url?.url(with: ImageQueryOptions(defaultAvatarOption: .transparentPNG)).query, "d=blank")
        XCTAssertEqual(url?.url(with: ImageQueryOptions(defaultAvatarOption: .wavatar)).query, "d=wavatar")
    }

    func testUrlWithForcedImageDefault() throws {
        let url = GravatarURL(verifiedGravatarURL)
        XCTAssertNotNil(url)
        XCTAssertEqual(url?.url(with: ImageQueryOptions()).query, nil)
        XCTAssertEqual(url?.url(with: ImageQueryOptions(forceDefaultImage: true)).query, "f=y")
    }

    func testUrlWithForceImageDefaultFalse() {
        let url = GravatarURL(verifiedGravatarURL)
        XCTAssertNotNil(url)
        XCTAssertEqual(url?.url(with: ImageQueryOptions()).query, nil)
        XCTAssertEqual(url?.url(with: ImageQueryOptions(forceDefaultImage: false)).query, "f=n")
    }

    func testCreateGravatarUrlWithEmail() throws {
        let url = GravatarURL.gravatarUrl(with: .email(exampleEmail), options: ImageQueryOptions())
        XCTAssertEqual(
            url?.absoluteString,
            "https://gravatar.com/avatar/676212ff796c79a3c06261eb10e3f455aa93998ee6e45263da13679c74b1e674"
        )

        let urlAddingDefaultImage = GravatarURL.gravatarUrl(with: .email(exampleEmail), options: ImageQueryOptions(defaultAvatarOption: .identicon))
        XCTAssertEqual(
            urlAddingDefaultImage?.absoluteString,
            "https://gravatar.com/avatar/676212ff796c79a3c06261eb10e3f455aa93998ee6e45263da13679c74b1e674?d=identicon"
        )

        let urlAddingSize = GravatarURL.gravatarUrl(with: .email(exampleEmail), options: ImageQueryOptions(preferredSize: .pixels(24)))
        XCTAssertEqual(
            urlAddingSize?.absoluteString,
            "https://gravatar.com/avatar/676212ff796c79a3c06261eb10e3f455aa93998ee6e45263da13679c74b1e674?s=24"
        )

        let urlAddingRating = GravatarURL.gravatarUrl(with: .email(exampleEmail), options: ImageQueryOptions(rating: .parentalGuidance))
        XCTAssertEqual(
            urlAddingRating?.absoluteString,
            "https://gravatar.com/avatar/676212ff796c79a3c06261eb10e3f455aa93998ee6e45263da13679c74b1e674?r=pg"
        )

        let urlAddingForceDefault = GravatarURL.gravatarUrl(with: .email(exampleEmail), options: ImageQueryOptions(forceDefaultImage: true))
        XCTAssertEqual(
            urlAddingForceDefault?.absoluteString,
            "https://gravatar.com/avatar/676212ff796c79a3c06261eb10e3f455aa93998ee6e45263da13679c74b1e674?f=y"
        )

        let allOptions = ImageQueryOptions(
            preferredSize: .pixels(200),
            rating: .general,
            defaultAvatarOption: .monsterId,
            forceDefaultImage: true
        )
        let urlAddingAllOptions = GravatarURL.gravatarUrl(with: .email(exampleEmail), options: allOptions)
        XCTAssertEqual(
            urlAddingAllOptions?.absoluteString,
            "https://gravatar.com/avatar/676212ff796c79a3c06261eb10e3f455aa93998ee6e45263da13679c74b1e674?d=monsterid&s=200&r=g&f=y"
        )
    }

    func testGravatarURLIsEquatable() throws {
        let lhs = GravatarURL(verifiedGravatarURL)
        let rhs = GravatarURL(verifiedGravatarURL)

        XCTAssertEqual(lhs, rhs)
    }

    func testGravatarURLIsEquatableFails() throws {
        let lhs = GravatarURL(URL(string: "https://www.gravatar.com/avatar/000")!)
        let rhs = GravatarURL(verifiedGravatarURL)

        XCTAssertNotEqual(lhs, rhs)
    }
}
