//
//  GravatarURLTests.swift
//  
//
//  Created by eToledo on 23/1/24.
//

import XCTest
@testable import Gravatar

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

    func testGravatarURLWithDifferentSizes() throws {
        let url = GravatarURL(verifiedGravatarURL)
        XCTAssertNotNil(url)
        let options = GravatarImageDownloadOptions(scaleFactor: 1)
        XCTAssertEqual(url?.url(with: options.updating(preferredSize: 24.toCGSize())).query, "s=24")
        XCTAssertEqual(url?.url(with: options.updating(preferredSize: 128.toCGSize())).query, "s=128")
        XCTAssertEqual(url?.url(with: options.updating(preferredSize: 256.toCGSize())).query, "s=256")
        XCTAssertEqual(url?.url(with: options.updating(preferredSize: 0.toCGSize())).query, "s=1")
        XCTAssertEqual(url?.url(with: options.updating(preferredSize: (-10).toCGSize())).query, "s=1")
        XCTAssertEqual(url?.url(with: options.updating(preferredSize: 5000.toCGSize())).query, "s=2024")
    }

    func testUrlWithDefaultImage() throws {
        let url = GravatarURL(verifiedGravatarURL)
        XCTAssertNotNil(url)
        let options = GravatarImageDownloadOptions()

        XCTAssertEqual(url?.url(with: options.updating(defaultImage: .defaultOption)).query, "d=404")
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
        XCTAssertEqual(url?.url(with: options.updating(forceDefaultImage: true)).query, "f=true")
    }

    func testCreateGravatarUrlWithEmail() throws {
        let emailPrefix = "https://gravatar.com/avatar/\(exampleEmailSHA)"

        let options = GravatarImageDownloadOptions(scaleFactor: 1)
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

        let urlAddingSize = GravatarURL.gravatarUrl(with: exampleEmail, options: options.updating(preferredSize: 24.toCGSize()))
        XCTAssertEqual(
            urlAddingSize?.absoluteString,
            "https://gravatar.com/avatar/676212ff796c79a3c06261eb10e3f455aa93998ee6e45263da13679c74b1e674?s=24"
        )

        let urlAddingRating = GravatarURL.gravatarUrl(with: exampleEmail, options: options.updating(gravatarRating: .pg))
        XCTAssertEqual(
            urlAddingRating?.absoluteString,
            "https://gravatar.com/avatar/676212ff796c79a3c06261eb10e3f455aa93998ee6e45263da13679c74b1e674?r=pg"
        )

        let allOptions = GravatarImageDownloadOptions(scaleFactor: 1, gravatarRating: .g, preferredSize: 200.toCGSize(), forceDefaultImage: true, defaultImage: .monsterId)
        let urlAddingAllOptions = GravatarURL.gravatarUrl(with: exampleEmail, options: allOptions)
        XCTAssertEqual(
            urlAddingAllOptions?.absoluteString,
            "https://gravatar.com/avatar/676212ff796c79a3c06261eb10e3f455aa93998ee6e45263da13679c74b1e674?d=monsterid&s=200&r=g&f=true"
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

extension Int {
    func toCGSize() -> CGSize {
        .init(width: self, height: self)
    }
}
