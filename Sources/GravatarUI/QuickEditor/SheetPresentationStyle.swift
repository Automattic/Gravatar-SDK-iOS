import Foundation

/// A value that describes how the Quick Editor sheet should be presented,
public struct SheetPresentationStyle: Sendable {
    public static let expandableMediumInitialFraction: CGFloat = 0.7

    enum DetentMode: Sendable {
        case large
        case expandableMedium(
            initialFraction: CGFloat = SheetPresentationStyle.expandableMediumInitialFraction,
            prioritizeScrollOverResize: Bool = false
        )
        case intrinsicHeight
        case automatic(prioritizeScrollOverResize: Bool = false)
    }

    let detentMode: DetentMode

    /// A full-height sheet presentation style.
    /// - Returns: A `SheetPresentationStyle` instance configured to present the sheet at full height.
    public static func large() -> SheetPresentationStyle {
        .init(detentMode: .large)
    }

    /// A medium-height sheet presentation style that can expand to full height.
    ///
    /// In a compact height size class environment, the medium-height presentation is disabled and the sheet is presented at full height by default.
    /// - Parameters:
    ///   - initialFraction: The fractional height (relative to the full height) at which the sheet is initially presented.
    ///   - prioritizeScrollOverResize: Determines whether scroll gestures within the sheet take precedence over resizing gestures. Available on iOS 16.4 and
    /// later.
    /// - Returns: A configured ``SheetPresentationStyle`` instance representing an expandable medium-height sheet.
    public static func expandableMedium(
        initialFraction: CGFloat = SheetPresentationStyle.expandableMediumInitialFraction,
        prioritizeScrollOverResize: Bool = false
    ) -> SheetPresentationStyle {
        .init(
            detentMode: .expandableMedium(
                initialFraction: initialFraction,
                prioritizeScrollOverResize: prioritizeScrollOverResize
            )
        )
    }

    /// Represents a bottom sheet with intrinsic height.
    ///
    /// There are 2 size classes where this mode is inactive:
    ///  - Compact height: The sheet is displayed in full height.
    ///  - Regular width: The system ignores the intrinsic height and defaults to a full size sheet by the system.
    public static func intrinsicHeight() -> SheetPresentationStyle {
        .init(detentMode: .intrinsicHeight)
    }

    /// Returns a sheet presentation style that automatically chooses between `.intrinsicHeight` and `.expandableMedium()`,
    /// depending on the content height.
    ///
    /// If the content height is below a predefined threshold, `.intrinsicHeight` is used;
    /// otherwise, `.expandableMedium()` is applied.
    ///
    /// - Parameter prioritizeScrollOverResize: Determines whether scroll gestures within the sheet take precedence over resizing gestures.
    ///   This parameter is effective only on iOS 16.4 and later.
    ///
    /// - Returns: A `SheetPresentationStyle` instance that adapts the sheet height based on content size.
    public static func automatic(prioritizeScrollOverResize: Bool = false) -> SheetPresentationStyle {
        .init(detentMode: .automatic(prioritizeScrollOverResize: prioritizeScrollOverResize))
    }

    var prioritizeScrollOverResize: Bool {
        switch detentMode {
        case .expandableMedium(_, let prioritizeScrollOverResize):
            prioritizeScrollOverResize
        case .automatic(let prioritizeScrollOverResize):
            prioritizeScrollOverResize
        case .intrinsicHeight:
            false
        case .large:
            false
        }
    }
}
