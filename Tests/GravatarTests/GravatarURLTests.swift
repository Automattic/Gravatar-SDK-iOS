//
//  GravatarURLTests.swift
//
//
//  Created by eToledo on 23/1/24.
//

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
        XCTAssertEqual(url?.url(with: GravatarImageDownloadOptions(preferredSize: .pixels(24))).query, "s=24")
        XCTAssertEqual(url?.url(with: GravatarImageDownloadOptions(preferredSize: .pixels(128))).query, "s=128")
        XCTAssertEqual(url?.url(with: GravatarImageDownloadOptions(preferredSize: .pixels(256))).query, "s=256")
        XCTAssertEqual(url?.url(with: GravatarImageDownloadOptions(preferredSize: .pixels(0))).query, "s=0")
        XCTAssertEqual(url?.url(with: GravatarImageDownloadOptions(preferredSize: .pixels(-10))).query, "s=-10")
    }

    func testGravatarUrlWithPointSize() throws {
        let gavatarUrl = GravatarURL(verifiedGravatarURL)
        let pointSize = CGFloat(200)
        let expectedPixelSize = pointSize * UIScreen.main.scale

        let url = gavatarUrl?.url(with: GravatarImageDownloadOptions(preferredSize: .points(pointSize)))

        XCTAssertNotNil(url)
        XCTAssertEqual(url?.query, "s=\(Int(expectedPixelSize))")
    }

    func testUrlWithDefaultImage() throws {
        let url = GravatarURL(verifiedGravatarURL)
        XCTAssertNotNil(url)
        let options = GravatarImageDownloadOptions()

        XCTAssertEqual(url?.url(with: options.updating(defaultImage: .fileNotFound)).query, "d=404")
        XCTAssertEqual(url?.url(with: options.updating(defaultImage: .misteryPerson)).query, "d=mp")
        XCTAssertEqual(url?.url(with: options.updating(defaultImage: .monsterId)).query, "d=monsterid")
        XCTAssertEqual(url?.url(with: options.updating(defaultImage: .retro)).query, "d=retro")
        XCTAssertEqual(url?.url(with: options.updating(defaultImage: .roboHash)).query, "d=robohash")
        XCTAssertEqual(url?.url(with: options.updating(defaultImage: .transparentPNG)).query, "d=blank")
        XCTAssertEqual(url?.url(with: options.updating(defaultImage: .wavatar)).query, "d=wavatar")
    }

    func testUrlWithForcedImageDefault() throws {
        let url = GravatarURL(verifiedGravatarURL)
        XCTAssertNotNil(url)
        let options = GravatarImageDownloadOptions()
        XCTAssertEqual(url?.url(with: options).query, nil)
        XCTAssertEqual(url?.url(with: options.updating(forceDefaultImage: true)).query, "f=y")
    }

    func testCreateGravatarUrlWithEmail() throws {
        let options = GravatarImageDownloadOptions()
        let url = GravatarURL.gravatarUrl(with: exampleEmail, options: options)
        XCTAssertEqual(
            url?.absoluteString,
            "https://gravatar.com/avatar/676212ff796c79a3c06261eb10e3f455aa93998ee6e45263da13679c74b1e674"
        )

        let urlAddingDefaultImage = GravatarURL.gravatarUrl(with: exampleEmail, options: options.updating(defaultImage: .identicon))
        XCTAssertEqual(
            urlAddingDefaultImage?.absoluteString,
            "https://gravatar.com/avatar/676212ff796c79a3c06261eb10e3f455aa93998ee6e45263da13679c74b1e674?d=identicon"
        )

        let urlAddingSize = GravatarURL.gravatarUrl(with: exampleEmail, options: GravatarImageDownloadOptions(preferredSize: .pixels(24)))
        XCTAssertEqual(
            urlAddingSize?.absoluteString,
            "https://gravatar.com/avatar/676212ff796c79a3c06261eb10e3f455aa93998ee6e45263da13679c74b1e674?s=24"
        )

        let urlAddingRating = GravatarURL.gravatarUrl(with: exampleEmail, options: options.updating(gravatarRating: .pg))
        XCTAssertEqual(
            urlAddingRating?.absoluteString,
            "https://gravatar.com/avatar/676212ff796c79a3c06261eb10e3f455aa93998ee6e45263da13679c74b1e674?r=pg"
        )

        let urlAddingForceDefault = GravatarURL.gravatarUrl(with: exampleEmail, options: options.updating(forceDefaultImage: true))
        XCTAssertEqual(
            urlAddingForceDefault?.absoluteString,
            "https://gravatar.com/avatar/676212ff796c79a3c06261eb10e3f455aa93998ee6e45263da13679c74b1e674?f=y"
        )

        let allOptions = GravatarImageDownloadOptions(
            preferredSize: .pixels(200),
            gravatarRating: .g,
            forceDefaultImage: true,
            defaultImage: .monsterId
        )
        let urlAddingAllOptions = GravatarURL.gravatarUrl(with: exampleEmail, options: allOptions)
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
