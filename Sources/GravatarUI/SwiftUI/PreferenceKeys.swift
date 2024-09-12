import SwiftUI

/// A `PreferenceKey` that is used to sum up all the heights of subviews.
struct InnerHeightPreferenceKey: PreferenceKey {
    static let defaultValue: CGFloat = .zero
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value += nextValue()
    }
}

protocol SizeClassPreferenceKey: PreferenceKey {}

/// A `PreferenceKey` to tell the `ViewModifier` about the size class.
/// (This is needed because the size class environment variables are only reachable in a View subclass not in a `ViewModifier`.)
extension SizeClassPreferenceKey {
    static func reduce(value: inout UserInterfaceSizeClass?, nextValue: () -> UserInterfaceSizeClass?) {
        let next = nextValue()
        if value == nil {
            value = next
        }
    }
}

struct VerticalSizeClassPreferenceKey: SizeClassPreferenceKey {
    static let defaultValue: UserInterfaceSizeClass? = nil
}

struct HorizontalSizeClassPreferenceKey: SizeClassPreferenceKey {
    static let defaultValue: UserInterfaceSizeClass? = nil
}
