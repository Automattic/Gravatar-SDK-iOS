//
//  GravatarOptionsTests.swift
//
//
//  Created by Pinar Olguc on 23.01.2024.
//

import XCTest
@testable import Gravatar

final class GravatarOptionsTests: XCTestCase {
    
    func testInitWithOptionList() throws {
        let gravatarOptions: [GravatarImageSettingOption] =
        [
            .forceRefresh,
            .removeCurrentImageWhileLoading,
            .scaleFactor(2.0),
            .transition(.fade(0.2)),
            .processor(TestImageProcessor()),
            .imageCache(TestImageCache()),
            .imageDownloader(TestImageRetriever(result: .success))
        ]
        
        let parsedOptions = GravatarImageSettingOptions(options: gravatarOptions)
        XCTAssertEqual(parsedOptions.forceRefresh, true)
        XCTAssertEqual(parsedOptions.removeCurrentImageWhileLoading, true)
        XCTAssertEqual(parsedOptions.scaleFactor, 2.0)
        XCTAssertEqual(parsedOptions.transition, GravatarImageTransition.fade(0.2))
        XCTAssertNotNil(parsedOptions.processor as? TestImageProcessor)
        XCTAssertNotNil(parsedOptions.imageCache as? TestImageCache)
        XCTAssertNotNil(parsedOptions.imageDownloader as? TestImageRetriever)
    }
    
    func testInitWithDefaultValues() throws {
        let parsedOptions = GravatarImageSettingOptions(options: nil)
        XCTAssertEqual(parsedOptions.forceRefresh, false)
        XCTAssertEqual(parsedOptions.removeCurrentImageWhileLoading, false)
        XCTAssertEqual(parsedOptions.scaleFactor, UIScreen.main.scale)
        XCTAssertEqual(parsedOptions.transition, GravatarImageTransition.none)
        XCTAssertNotNil(parsedOptions.processor as? DefaultImageProcessor)
    }
}

class TestImageProcessor: GravatarImageProcessor {
    var processedData = false
    func process(_ data: Data) -> UIImage? {
        processedData = true
        return UIImage()
    }
}
