import Foundation

protocol Clampable {
    associatedtype Bound: Comparable
    func clamped(to range: ClosedRange<Bound>) -> Bound
}

extension Clampable where Self: FloatingPoint {
    func clamped(to range: ClosedRange<Self>) -> Self {
        Self.minimum(Self.maximum(self, range.lowerBound), range.upperBound)
    }
}

extension CGFloat: Clampable {}
