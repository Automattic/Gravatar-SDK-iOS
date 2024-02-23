//
//  GravatarImageCacheTests.swift
//
//
//  Created by Pinar Olguc on 26.01.2024.
//

@testable import Gravatar
import XCTest

final class GravatarImageCacheTests: XCTestCase {
    private let key: String = "key"

    func testSetAndGet() throws {
        let cache = GravatarImageCache()
        cache.setImage(ImageHelper.testImage, forKey: key)
        XCTAssertNotNil(cache.getImage(forKey: key))
    }
}
