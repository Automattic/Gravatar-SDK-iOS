import Foundation
import Testing

@testable import Gravatar

struct ClampableTests {
    @Test("CGFloat outside of positive range does clamp")
    func cgFloatOutOfPositiveRangeDoesClamp() async throws {
        #expect(CGFloat(2.0).clamped(to: 0.0 ... 1.0) == 1.0)
        #expect(CGFloat(1_000_000.0).clamped(to: 0.0 ... 1.0) == 1.0)
        #expect(CGFloat(-2.0).clamped(to: 0.0 ... 1.0) == 0.0)
        #expect(CGFloat(-1_000_000.0).clamped(to: 0.0 ... 1.0) == 0.0)
        #expect(CGFloat(1.0001).clamped(to: 0.0 ... 1.0) == 1.0)
    }

    @Test("CGFloat outside of negative range does clamp")
    func cgFloatOutOfNegativeRangeDoesClamp() async throws {
        #expect(CGFloat(2.0).clamped(to: -1.0 ... 0.0) == 0.0)
        #expect(CGFloat(1_000_000.0).clamped(to: -1.0 ... 0.0) == 0.0)
        #expect(CGFloat(-2.0).clamped(to: -1.0 ... 0.0) == -1.0)
        #expect(CGFloat(-1_000_000.0).clamped(to: -1.0 ... 0.0) == -1.0)
        #expect(CGFloat(0.0001).clamped(to: -1.0 ... 0.0) == 0.0)
    }

    @Test("Unusual CGFloat does clamp")
    func unusualNumbersDoClamp() async throws {
        #expect(CGFloat.infinity.clamped(to: 0.0 ... 1.0) == 1.0)
        #expect(CGFloat.greatestFiniteMagnitude.clamped(to: 0.0 ... 1.0) == 1.0)
        #expect(CGFloat.leastNonzeroMagnitude.clamped(to: 1.0 ... 2.0) == 1.0)
        #expect(CGFloat.zero.clamped(to: 1.0 ... 2.0) == 1.0)
        #expect((-CGFloat.leastNonzeroMagnitude).clamped(to: 1.0 ... 2.0) == 1.0)
        #expect((-CGFloat.greatestFiniteMagnitude).clamped(to: 1.0 ... 2.0) == 1.0)
        #expect((-CGFloat.infinity).clamped(to: 1.0 ... 2.0) == 1.0)
        #expect(CGFloat.nan.clamped(to: 1.0 ... 2.0) == 1.0)
    }

    @Test("CGFloat within range does not clamp")
    func testCGFloatInRangeDoesNotClamp() async throws {
        #expect(CGFloat(1.0).clamped(to: 0.0 ... 1.0) == 1.0)
        #expect(CGFloat(0.5).clamped(to: 0.0 ... 1.0) == 0.5)
        #expect(CGFloat(0.0).clamped(to: 0.0 ... 1.0) == 0.0)
        #expect(CGFloat(0.0001).clamped(to: 0.0 ... 1.0) == 0.0001)
    }
}
