import Foundation
import Testing

@testable import Gravatar

@Suite("Clamping")
struct ClampingTests {
    static let positiveRange: ClosedRange<CGFloat> = 0.0 ... 1.0
    static let negativeRange: ClosedRange<CGFloat> = -1.0 ... 0.0

    @Suite("CGFloat does clamp")
    struct CGFloatDoesClampTests {
        @Test("Positive range: 0 ... 1", arguments: [
            ClampTest(2.0, clampedTo: positiveRange, returns: 1.0),
            ClampTest(1_000_000.0, clampedTo: positiveRange, returns: 1.0),
            ClampTest(-2.0, clampedTo: positiveRange, returns: 0.0),
            ClampTest(-1_000_000.0, clampedTo: positiveRange, returns: 0.0),
            ClampTest(1.0001, clampedTo: positiveRange, returns: 1.0),
        ])
        func cgFloatDoesClampToPositiveRange(clampTest: ClampTest) {
            #expect(clampTest.value.clamped(to: clampTest.range) == clampTest.expectedResult)
        }

        @Test("Negative range: -1 ... 0", arguments: [
            ClampTest(2.0, clampedTo: negativeRange, returns: 0.0),
            ClampTest(1_000_000.0, clampedTo: negativeRange, returns: 0.0),
            ClampTest(-2.0, clampedTo: negativeRange, returns: -1.0),
            ClampTest(-1_000_000.0, clampedTo: negativeRange, returns: -1.0),
            ClampTest(1.0001, clampedTo: negativeRange, returns: 0.0)
        ])
        func cgFloatDoesClampToNegativeRange(clampTest: ClampTest) {
            #expect(clampTest.value.clamped(to: clampTest.range) == clampTest.expectedResult)
        }

        @Test("Unusual CGFloats", arguments: [
            ClampTest(.infinity, clampedTo: positiveRange, returns: 1.0),
            ClampTest(.greatestFiniteMagnitude, clampedTo: positiveRange, returns: 1.0),
            ClampTest(.leastNonzeroMagnitude, clampedTo: 1.0 ... 2.0, returns: 1.0),
            ClampTest(.zero, clampedTo: 1.0 ... 2.0, returns: 1.0),
            ClampTest(-.leastNonzeroMagnitude, clampedTo: 1.0 ... 2.0, returns: 1.0),
            ClampTest(-.greatestFiniteMagnitude, clampedTo: 1.0 ... 2.0, returns: 1.0),
            ClampTest(-.infinity, clampedTo: 1.0 ... 2.0, returns: 1.0),
            ClampTest(.nan, clampedTo: 1.0 ... 2.0, returns: 1.0),
        ])
        func unusualNumbersDoClamp(clampTest: ClampTest) async throws {
            #expect(clampTest.value.clamped(to: clampTest.range) == clampTest.expectedResult)
        }
    }

    @Test("CGFloat does not clamp", arguments: [
        ClampTest(1.0, clampedTo: positiveRange, returns: 1.0),
        ClampTest(0.5, clampedTo: positiveRange, returns: 0.5),
        ClampTest(0.0, clampedTo: positiveRange, returns: 0.0),
        ClampTest(0.0001, clampedTo: positiveRange, returns: 0.0001),
    ])
    func testCGFloatInRangeDoesNotClamp(clampTest: ClampTest) async throws {
        #expect(clampTest.value.clamped(to: clampTest.range) == clampTest.expectedResult)
    }
}

struct ClampTest: CustomTestStringConvertible {
    let value: CGFloat
    let range: ClosedRange<CGFloat>
    let expectedResult: CGFloat

    var testDescription: String {
        "\(value) clamped to \(range) -> \(expectedResult)"
    }

    init(_ value: CGFloat, clampedTo range: ClosedRange<CGFloat>, returns expectedResult: CGFloat) {
        self.value = value
        self.range = range
        self.expectedResult = expectedResult
    }
}
