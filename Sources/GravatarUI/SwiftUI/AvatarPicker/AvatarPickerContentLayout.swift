import Foundation
import SwiftUI

/// Presentation styles supported for the verticially scrolling content.
public enum VerticalContentPresentationStyle: Sendable, Equatable {
    /// Full height sheet.
    case large

    /// Medium height sheet that is extendable to full height. In compact height this is inactive and the sheet is displayed as full height.
    /// - initialFraction: The fractional height of the sheet in its initial state.
    /// - prioritizeScrollOverResize: A behavior that prioritizes scrolling the content of the sheet when
    /// swiping, rather than resizing it. Note that this parameter is effective only for iOS 16.4 +.
    case extendableMedium(initialFraction: CGFloat = 0.7, prioritizeScrollOverResize: Bool = false)
}

/// Presentation styles supported for the horizontially scrolling content.
public enum HorizontalContentPresentationStyle: String, Sendable, Equatable {
    /// Represents a bottom sheet with intrinsic height.
    /// There are 2 size classes where this mode is inactive:
    ///  - Compact height: The sheet is displayed in full height.
    ///  - Regular width: The system ignores the intrinsic height and defaults to a full size sheet which is
    ///  something out of our control so the content is displayed as a verticially scrolling grid.
    case intrinsicHeight
}

/// Content layout to use iOS 16.0 +.
public enum AvatarPickerContentLayoutWithPresentation: AvatarPickerContentLayoutProviding, Equatable {
    /// Displays avatars in a vertcally scrolling grid with the given presentation style. See: ``VerticalContentPresentationStyle``
    case vertical(presentationStyle: VerticalContentPresentationStyle = .large)

    /// Displays avatars in a horizontally scrolling grid with the given presentation style. The grid constists of 1 row . See:
    /// ``HorizontalContentPresentationStyle``
    case horizontal(presentationStyle: HorizontalContentPresentationStyle = .intrinsicHeight)

    // MARK: AvatarPickerContentLayoutProviding

    var contentLayout: AvatarPickerContentLayout {
        switch self {
        case .horizontal:
            .horizontal
        case .vertical:
            .vertical
        }
    }
}

/// Content layout to use pre iOS 16.0 where the system don't offer different presentation styles for SwiftUI.
/// Use ``AvatarPickerContentLayoutWithPresentation`` for iOS 16.0 +.
public enum AvatarPickerContentLayout: String, CaseIterable, Identifiable, AvatarPickerContentLayoutProviding {
    public var id: Self { self }

    /// Displays avatars in a vertcally scrolling grid.
    case vertical
    /// Displays avatars in a horizontally scrolling grid that consists of 1 row.
    case horizontal

    // MARK: AvatarPickerContentLayoutProviding

    var contentLayout: AvatarPickerContentLayout { self }
}

/// Internal type. This is an abstraction over `AvatarPickerContentLayout` and `AvatarPickerContentLayoutWithPresentation`
/// to use when all we are interested is to find out if the content is horizontial or vertical.
protocol AvatarPickerContentLayoutProviding: Sendable {
    var contentLayout: AvatarPickerContentLayout { get }
}
