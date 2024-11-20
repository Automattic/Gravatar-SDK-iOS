import Foundation
import Testing

@testable import Gravatar

@Suite("ImageSize")
struct ImageSizeTests {
    private static let scaleFactors: [ScaleFactor] = [.init(1.0), .init(2.0), .init(3.0)]

    @Test("From Points", arguments: scaleFactors)
    func pixelsConversionFromPoints(atScaleFactor scaleFactor: ScaleFactor) {
        // Given
        let points: CGFloat = 50
        let imageSize = ImageSize.points(points)

        // When
        let result = imageSize.pixels(scaleFactor: scaleFactor.scale)

        // Then
        #expect(CGFloat(result) == (points * scaleFactor.scale))
    }

    @Test("From Pixels", arguments: scaleFactors)
    func pixelsConversionFromPixels(atScaleFactor scaleFactor: ScaleFactor) {
        // Given
        let imageSize = ImageSize.pixels(200)

        // When
        let result = imageSize.pixels(scaleFactor: scaleFactor.scale)

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

struct ScaleFactor: CustomTestStringConvertible {
    let scale: CGFloat

    init(_ scale: CGFloat) {
        self.scale = scale
    }

    var testDescription: String {
        "At scale factor \(scale)"
    }
}
