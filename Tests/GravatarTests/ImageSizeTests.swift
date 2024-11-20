import Foundation
import Testing

@testable import Gravatar

enum ImageSizeTests {
    private static let scaleFactors: [CGFloat] = [1.0, 2.0, 3.0]

    @Suite("Pixel Conversions")
    struct PixelConversionTests {
        @Test("From Points", arguments: scaleFactors)
        func pixelsConversionFromPoints(atScaleFactor scaleFactor: CGFloat) {
            // Given
            let points: CGFloat = 50
            let imageSize = ImageSize.points(points)

            // When
            let result = imageSize.pixels(scaleFactor: scaleFactor)

            // Then
            #expect(CGFloat(result) == (points * scaleFactor))
        }

        @Test("From Pixels", arguments: scaleFactors)
        func pixelsConversionFromPixels(atScaleFactor scaleFactor: CGFloat) {
            // Given
            let imageSize = ImageSize.pixels(200)

            // When
            let result = imageSize.pixels(scaleFactor: scaleFactor)

            // Then
            #expect(result == 200, "Expected pixels case to directly return the same pixel value")
        }

        @Test("Zero Scale Factor")
        func pixelsConversionWithZeroScaleFactor() {
            // Given
            let imageSize = ImageSize.points(50)
            let scaleFactor: CGFloat = 0.0 // Invalid scale factor

            // When
            let result = imageSize.pixels(scaleFactor: scaleFactor)

            // Then
            #expect(result == 0, "Expected pixels conversion to return 0 for a zero scale factor")
        }
    }

    @Suite("Point Conversions")
    struct PointConventionTests {
        @Test("From Pixels", arguments: scaleFactors)
        func pointsConversionFromPixels(atScaleFactor scaleFactor: CGFloat) {
            // Given
            let pixels = 200
            let imageSize = ImageSize.pixels(pixels)

            // When
            let result = imageSize.points(scaleFactor: scaleFactor)

            // Then
            #expect(result == (CGFloat(pixels) / scaleFactor))
        }

        @Test("From Points", arguments: scaleFactors)
        func pointsConversionFromPoints(atScaleFactor scaleFactor: CGFloat) {
            // Given
            let imageSize = ImageSize.points(40)

            // When
            let result = imageSize.points(scaleFactor: scaleFactor)

            // Then
            #expect(result == 40, "Expected points case to directly return the same point value")
        }

        @Test("Zero Scale Factor")
        func pointsConversionWithZeroScaleFactor() {
            // Given
            let imageSize = ImageSize.pixels(200)
            let scaleFactor: CGFloat = 0.0 // Invalid scale factor

            // When
            let result = imageSize.points(scaleFactor: scaleFactor)

            // Then
            #expect(result == 0, "Expected points conversion to return 0 for a zero scale factor")
        }
    }
}
