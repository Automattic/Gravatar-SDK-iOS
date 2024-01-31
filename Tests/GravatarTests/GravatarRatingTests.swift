//
//  GravatarRatingTests.swift
//  
//
//  Created by eToledo on 23/1/24.
//

import XCTest
@testable import Gravatar

final class GravatarRatingTests: XCTestCase {
    func testDefaultIsG() throws {
        let defaultRating = GravatarRating.default
        XCTAssertEqual(defaultRating.stringValue(), GravatarRating.g.stringValue())
   }
}
