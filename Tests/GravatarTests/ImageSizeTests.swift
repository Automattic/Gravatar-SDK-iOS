//
//  ImageSizeTests.swift
//
//
//  Created by Andrew Montgomery on 2/29/24.
//
import Gravatar
import XCTest

final class ImageSizeTests: XCTestCase {
    func testPointsToPixelsToPoints() {
        let imageWidths: [CGFloat] = [-10, 0, 80, 128, 256, 12.37654, 215.1, 215.2, 215.3, 215.4, 215.5, 215.6, 215.7, 215.8, 215.9]

        for imageWidth in imageWidths {
            let imageSize1WithPoints = ImageSize(points: imageWidth)
            let imageWidth1InPixels = imageSize1WithPoints.pixels
            let imageSize2WithPixels = ImageSize(pixels: imageWidth1InPixels)

            XCTAssertEqual(imageSize1WithPoints, imageSize2WithPixels)
        }
    }

    func testInitImageSizeWithNilPointsReturnNilImageSize() {
        let sut = ImageSize(points: nil)
        XCTAssertNil(sut)
    }

    func testInitImageSizeWithOptionalPointsReturnsOptionalImageSize() {
        let imageWidth: CGFloat? = 80
        let sut = ImageSize(points: imageWidth)
        XCTAssertNotNil(sut)
    }

    func testImageSizesWithSamePointsSameScaleAreEqual() {
        let imageWidths: [CGFloat] = [-10, 0, 80, 128, 256, 12.37654]
        for imageWidth in imageWidths {
            let imageSize1 = ImageSize(points: imageWidth, scaleFactor: 2)
            let imageSize2 = ImageSize(points: imageWidth, scaleFactor: 2)
            XCTAssertEqual(imageSize1, imageSize2)
        }
    }

    func testImageSizesWithSamePointsDifferentScaleNotEqual() {
        let imageWidths: [CGFloat] = [-10, 0, 80, 128, 256, 12.37654]
        for imageWidth in imageWidths {
            let imageSize1 = ImageSize(points: imageWidth, scaleFactor: 1)
            let imageSize2 = ImageSize(points: imageWidth, scaleFactor: 2)
            XCTAssertNotEqual(imageSize1, imageSize2)
        }
    }

    func testImageSizesWithSamePixelsSameScaleAreEqual() {
        let imageWidths = [-10, 0, 80, 128, 256]
        for imageWidth in imageWidths {
            let imageSize1 = ImageSize(pixels: imageWidth, scaleFactor: 2)
            let imageSize2 = ImageSize(pixels: imageWidth, scaleFactor: 2)
            XCTAssertEqual(imageSize1, imageSize2)
        }
    }

    func testImageSizesWithSamePixelsDifferentScaleNotEqual() {
        let imageWidths = [-10, 0, 80, 128, 256]
        for imageWidth in imageWidths {
            let imageSize1 = ImageSize(pixels: imageWidth, scaleFactor: 1)
            let imageSize2 = ImageSize(pixels: imageWidth, scaleFactor: 2)
            XCTAssertNotEqual(imageSize1, imageSize2)
        }
    }

    func testImageSizeInPixelsWhenCreatedInPoints() {
        let imageWidths: [CGFloat] = [-10, 0, 80, 128, 256, 12.37654]
        let scaleFactors: [CGFloat] = [1, 2, 3]

        for scaleFactor in scaleFactors {
            for imageWidth in imageWidths {
                let sut = ImageSize(points: imageWidth, scaleFactor: scaleFactor)
                XCTAssertEqual(sut.pixels, Int((imageWidth * scaleFactor).rounded()))
            }
        }
    }

    func testImageSizeInPointsWhenCreatedInPixels() {
        let imageWidths = [-10, 0, 80, 128, 256]
        let scaleFactors: [CGFloat] = [1, 2, 3]

        for scaleFactor in scaleFactors {
            for imageWidth in imageWidths {
                let sut = ImageSize(pixels: imageWidth, scaleFactor: scaleFactor)
                XCTAssertEqual(sut.points, CGFloat(imageWidth) / scaleFactor)
            }
        }
    }

    func testImageSizeFromCGSizeWithFill() {
        let sizes: [CGSize] = [
            CGSize(width: 80.0, height: 80.0),
            CGSize(width: 12.37654, height: 12.37654),
            CGSize(width: 80.0, height: 128.0),
            CGSize(width: 128.0, height: 80.0),
        ]

        let scaleFactors: [CGFloat] = [1, 2, 3]
        let fillType: CGSize.ImageSizeFillType = .fill

        for scaleFactor in scaleFactors {
            for size in sizes {
                guard let sut = ImageSize(size: size, fillType: fillType, scaleFactor: scaleFactor) else {
                    XCTFail("Non-nil CGSize should return non-nil ImageSize")
                    return
                }

                let expectedWidth = max(size.width, size.height)

                XCTAssertEqual(sut.points, expectedWidth)
            }
        }
    }

    func testImageSizeFromCGSizeWithFit() {
        let sizes: [CGSize] = [
            CGSize(width: 80.0, height: 80.0),
            CGSize(width: 12.37654, height: 12.37654),
            CGSize(width: 80.0, height: 128.0),
            CGSize(width: 128.0, height: 80.0),
        ]

        let scaleFactors: [CGFloat] = [1, 2, 3]
        let fillType: CGSize.ImageSizeFillType = .fit

        for scaleFactor in scaleFactors {
            for size in sizes {
                guard let sut = ImageSize(size: size, fillType: fillType, scaleFactor: scaleFactor) else {
                    XCTFail("Non-nil CGSize should return non-nil ImageSize")
                    return
                }

                let expectedWidth = min(size.width, size.height)

                XCTAssertEqual(sut.points, expectedWidth)
            }
        }
    }
}
