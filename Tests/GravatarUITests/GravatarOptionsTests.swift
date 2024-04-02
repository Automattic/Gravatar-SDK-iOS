@testable import Gravatar
@testable import GravatarUI
import TestHelpers
import XCTest

final class GravatarOptionsTests: XCTestCase {
    func testInitWithOptionList() throws {
        let gravatarOptions: [ImageSettingOption] =
            [
                .forceRefresh,
                .removeCurrentImageWhileLoading,
                .transition(.fade(0.2)),
                .processingMethod(.custom(processor: TestImageProcessor())),
                .imageCache(TestImageCache()),
                .imageDownloader(TestImageFetcher(result: .success)),
            ]

        let parsedOptions = ImageSettingOptions(options: gravatarOptions)
        XCTAssertEqual(parsedOptions.forceRefresh, true)
        XCTAssertEqual(parsedOptions.removeCurrentImageWhileLoading, true)
        XCTAssertEqual(parsedOptions.transition, ImageTransition.fade(0.2))
        XCTAssertNotNil(parsedOptions.processingMethod.processor as? TestImageProcessor)
        XCTAssertNotNil(parsedOptions.imageCache as? TestImageCache)
        XCTAssertNotNil(parsedOptions.imageDownloader as? TestImageFetcher)
    }

    func testInitWithDefaultValues() throws {
        let parsedOptions = ImageSettingOptions(options: nil)
        XCTAssertEqual(parsedOptions.forceRefresh, false)
        XCTAssertEqual(parsedOptions.removeCurrentImageWhileLoading, false)
        XCTAssertEqual(parsedOptions.transition, ImageTransition.none)
        XCTAssertNotNil(parsedOptions.processingMethod.processor as? DefaultImageProcessor)
    }
}
