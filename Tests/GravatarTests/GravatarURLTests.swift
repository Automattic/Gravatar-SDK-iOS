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

    func testUrlWithSize() throws {
        let url = GravatarURL(verifiedGravatarURL)
        XCTAssertNotNil(url)

        let urlWithSize = url?.urlWithSize(24, defaultImage: .defaultOption)
        XCTAssertTrue(urlWithSize?.absoluteString.hasSuffix("?s=24&d=404") ?? false)

        let urlWithSizeAndMisteryPersonDefault = url?.urlWithSize(128, defaultImage: .misteryPerson)
        XCTAssertTrue(urlWithSizeAndMisteryPersonDefault?.absoluteString.hasSuffix("?s=128&d=mp") ?? false)

        let urlWithSizeAndIdenticonDefault = url?.urlWithSize(256, defaultImage: .identicon)
        XCTAssertTrue(urlWithSizeAndIdenticonDefault?.absoluteString.hasSuffix("?s=256&d=identicon") ?? false)
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
