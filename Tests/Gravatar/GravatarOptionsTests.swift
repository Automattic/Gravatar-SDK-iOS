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
        let size = CGSize(width: 10, height: 10)
        let gravatarOptions: [GravatarImageSettingOption] =
        [
            .cancelOngoingDownload,
            .forceRefresh,
            .removeCurrentImageWhileLoading,
            .gravatarRating(.pg),
            .preferredSize(size),
            .scaleFactor(2.0),
            .transition(.fade(0.2)),
            .processor(TestImageProcessor())
        ]
        
        let parsedOptions = GravatarImageSettingOptions(options: gravatarOptions)
        XCTAssertEqual(parsedOptions.shouldCancelOngoingDownload, true)
        XCTAssertEqual(parsedOptions.forceRefresh, true)
        XCTAssertEqual(parsedOptions.removeCurrentImageWhileLoading, true)
        XCTAssertEqual(parsedOptions.gravatarRating, GravatarRating.pg)
        XCTAssertEqual(parsedOptions.preferredSize, size)
        XCTAssertEqual(parsedOptions.scaleFactor, 2.0)
        XCTAssertEqual(parsedOptions.transition, GravatarImageTransition.fade(0.2))
        XCTAssertNotNil(parsedOptions.processor as? TestImageProcessor)
    }
    
    func testInitWithDefaultValues() throws {
        let parsedOptions = GravatarImageSettingOptions(options: nil)
        XCTAssertEqual(parsedOptions.shouldCancelOngoingDownload, false)
        XCTAssertEqual(parsedOptions.forceRefresh, false)
        XCTAssertEqual(parsedOptions.removeCurrentImageWhileLoading, false)
        XCTAssertEqual(parsedOptions.gravatarRating, GravatarRating.default)
        XCTAssertEqual(parsedOptions.preferredSize, nil)
        XCTAssertEqual(parsedOptions.scaleFactor, UIScreen.main.scale)
        XCTAssertEqual(parsedOptions.transition, GravatarImageTransition.none)
        XCTAssertNotNil(parsedOptions.processor as? DefaultImageProcessor)
    }
}

private struct TestImageProcessor: GravatarImageProcessor {
    func process(_ data: Data, options: GravatarImageDownloadOptions) -> UIImage? {
        return nil
    }
}
