import Foundation

extension FloatingPoint {
    /// Constrains a value to a specified closed range.
    ///
    ///  Use this method to ensure that a value does not fall below the lower bound or exceed the upper bound of a specified range.
    /// - Parameter range: A closed range that defines the acceptable bounds for the value.
    /// - Returns: The value clamped to the bounds of `range`. If the value is less than `range.lowerBound`, this method returns
    /// `range.lowerBound`. If the value is greater than `range.upperBound`, this method returns `range.upperBound`.
    /// Otherwise, the original value is returned.
    func clamped(to range: ClosedRange<Self>) -> Self {
        Self.minimum(Self.maximum(self, range.lowerBound), range.upperBound)
    }
}
