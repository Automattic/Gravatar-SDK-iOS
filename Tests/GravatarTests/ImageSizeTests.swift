import Foundation
import Testing

@testable import Gravatar

@Suite("ImageSize")
struct ImageSizeTests {
    @Test("From Points", arguments: ScaleFactor.allCases)
    func pixelsConversionFromPoints(atScaleFactor scaleFactor: ScaleFactor) {
        // Given
        let points: CGFloat = 50
        let imageSize = ImageSize.points(points)

        // When
        let result = imageSize.pixels(scaleFactor: scaleFactor.scale)

        // Then
        #expect(CGFloat(result) == (points * scaleFactor.scale))
    }

    @Test("From Pixels", arguments: ScaleFactor.allCases)
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
    static let one: ScaleFactor = .init(1.0)
    static let two: ScaleFactor = .init(2.0)
    static let three: ScaleFactor = .init(3.0)
    static let allCases: [ScaleFactor] = [.one, .two, .three]

    let scale: CGFloat

    init(_ scale: CGFloat) {
        self.scale = scale
    }

    var testDescription: String {
        "@ \(scale)x"
    }
}
