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

        XCTAssertEqual(url?.url(with: 24).query, "s=24&d=404")
        XCTAssertEqual(url?.url(with: 128).query, "s=128&d=404")
        XCTAssertEqual(url?.url(with: 256).query, "s=256&d=404")
        XCTAssertEqual(url?.url(with: 0).query, "s=1&d=404")
        XCTAssertEqual(url?.url(with: -10).query, "s=1&d=404")
        XCTAssertEqual(url?.url(with: 5000).query, "s=2024&d=404")
    }

    func testUrlWithDefaultImage() throws {
        let url = GravatarURL(verifiedGravatarURL)
        XCTAssertNotNil(url)

        XCTAssertEqual(url?.url(defaultImage: .defaultOption).query, "d=404")
        XCTAssertEqual(url?.url(defaultImage: .fileNotFound).query, "d=404")
        XCTAssertEqual(url?.url(defaultImage: .misteryPerson).query, "d=mp")
        XCTAssertEqual(url?.url(defaultImage: .monsterId).query, "d=monsterid")
        XCTAssertEqual(url?.url(defaultImage: .retro).query, "d=retro")
        XCTAssertEqual(url?.url(defaultImage: .roboHash).query, "d=robohash")
        XCTAssertEqual(url?.url(defaultImage: .transparentPNG).query, "d=blank")
        XCTAssertEqual(url?.url(defaultImage: .wavatar).query, "d=wavatar")
    }

    func testCreateGravatarUrl() throws {
        let emailPrefix = "https://gravatar.com/avatar/\(exampleEmailSHA)"

        let url = GravatarURL.gravatarUrl(for: exampleEmail)
        XCTAssertEqual(url?.absoluteString, "\(emailPrefix)?d=404&s=80&r=g")

        let urlWithDefaultImage = GravatarURL.gravatarUrl(for: exampleEmail, defaultImage: .identicon)
        XCTAssertEqual(urlWithDefaultImage?.absoluteString, "\(emailPrefix)?d=identicon&s=80&r=g")

        let urlWithSize = GravatarURL.gravatarUrl(for: exampleEmail, size: 24)
        XCTAssertEqual(urlWithSize?.absoluteString, "\(emailPrefix)?d=404&s=24&r=g")

        let urlWithRating = GravatarURL.gravatarUrl(for: exampleEmail, rating: .pg)
        XCTAssertEqual(urlWithRating?.absoluteString, "\(emailPrefix)?d=404&s=80&r=pg")

        let urlWithZeroSize = GravatarURL.gravatarUrl(for: exampleEmail, size: 0)
        XCTAssertEqual(urlWithZeroSize?.absoluteString, "\(emailPrefix)?d=404&s=1&r=g")

        let urlWithNegativeSize = GravatarURL.gravatarUrl(for: exampleEmail, size: -20)
        XCTAssertEqual(urlWithNegativeSize?.absoluteString, "\(emailPrefix)?d=404&s=1&r=g")

        let urlWithBigSize = GravatarURL.gravatarUrl(for: exampleEmail, size: 2025)
        XCTAssertEqual(urlWithBigSize?.absoluteString, "\(emailPrefix)?d=404&s=2024&r=g")
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
