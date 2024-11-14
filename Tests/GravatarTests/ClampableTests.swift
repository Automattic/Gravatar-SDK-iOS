import Foundation
import Testing

@testable import Gravatar

struct ClampableTests {
    @Test
    func testCGFloatOutOfRangeDoesClamp() async throws {
        // Test positive ranges
        #expect(CGFloat(2.0).clamped(to: 0.0 ... 1.0) == 1.0)
        #expect(CGFloat(1_000_000.0).clamped(to: 0.0 ... 1.0) == 1.0)
        #expect(CGFloat(-2.0).clamped(to: 0.0 ... 1.0) == 0.0)
        #expect(CGFloat(-1_000_000.0).clamped(to: 0.0 ... 1.0) == 0.0)
        #expect(CGFloat(1.0001).clamped(to: 0.0 ... 1.0) == 1.0)

        // Test negative ranges
        #expect(CGFloat(2.0).clamped(to: -1.0 ... 0.0) == 0.0)
        #expect(CGFloat(1_000_000.0).clamped(to: -1.0 ... 0.0) == 0.0)
        #expect(CGFloat(-2.0).clamped(to: -1.0 ... 0.0) == -1.0)
        #expect(CGFloat(-1_000_000.0).clamped(to: -1.0 ... 0.0) == -1.0)
        #expect(CGFloat(0.0001).clamped(to: -1.0 ... 0.0) == 0.0)

        // Test unusaul numbers
        #expect(CGFloat.infinity.clamped(to: 0.0 ... 1.0) == 1.0)
        #expect(CGFloat.greatestFiniteMagnitude.clamped(to: 0.0 ... 1.0) == 1.0)
        #expect(CGFloat.leastNonzeroMagnitude.clamped(to: 1.0 ... 2.0) == 1.0)
        #expect(CGFloat.zero.clamped(to: 1.0 ... 2.0) == 1.0)
        #expect((-CGFloat.leastNonzeroMagnitude).clamped(to: 1.0 ... 2.0) == 1.0)
        #expect((-CGFloat.greatestFiniteMagnitude).clamped(to: 1.0 ... 2.0) == 1.0)
        #expect((-CGFloat.infinity).clamped(to: 1.0 ... 2.0) == 1.0)
        #expect(CGFloat.nan.clamped(to: 1.0 ... 2.0) == 1.0)
    }

    @Test
    func testCGFloatInRangeDoesNotClamp() async throws {
        #expect(CGFloat(1.0).clamped(to: 0.0 ... 1.0) == 1.0)
        #expect(CGFloat(0.5).clamped(to: 0.0 ... 1.0) == 0.5)
        #expect(CGFloat(0.0).clamped(to: 0.0 ... 1.0) == 0.0)
        #expect(CGFloat(0.0001).clamped(to: 0.0 ... 1.0) == 0.0001)
    }
}
