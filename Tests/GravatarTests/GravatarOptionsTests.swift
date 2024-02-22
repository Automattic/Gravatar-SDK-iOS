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
            .transition(.fade(0.2)),
            .processingMethod(.custom(processor: TestImageProcessor())),
            .imageCache(TestImageCache()),
            .imageDownloader(TestImageRetriever(result: .success))
        ]
        
        let parsedOptions = GravatarImageSettingOptions(options: gravatarOptions)
        XCTAssertEqual(parsedOptions.forceRefresh, true)
        XCTAssertEqual(parsedOptions.removeCurrentImageWhileLoading, true)
        XCTAssertEqual(parsedOptions.transition, GravatarImageTransition.fade(0.2))
        XCTAssertNotNil(parsedOptions.processingMethod.processor as? TestImageProcessor)
        XCTAssertNotNil(parsedOptions.imageCache as? TestImageCache)
        XCTAssertNotNil(parsedOptions.imageDownloader as? TestImageRetriever)
    }
    
    func testInitWithDefaultValues() throws {
        let parsedOptions = GravatarImageSettingOptions(options: nil)
        XCTAssertEqual(parsedOptions.forceRefresh, false)
        XCTAssertEqual(parsedOptions.removeCurrentImageWhileLoading, false)
        XCTAssertEqual(parsedOptions.transition, GravatarImageTransition.none)
        XCTAssertNotNil(parsedOptions.processingMethod.processor as? DefaultImageProcessor)
    }
}

class TestImageProcessor: ImageProcessor {
    var processedData = false
    func process(_ data: Data) -> UIImage? {
        processedData = true
        return UIImage()
    }
}
