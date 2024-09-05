import Foundation
import SwiftUI

public enum VerticalContentPresentationStyles: Sendable, Equatable {
    case large
    case extendableMedium(initialFraction: CGFloat = 0.7, prioritizeScrollingOverResizing: Bool = false)
}

public enum HorizontalContentPresentationStyles: String, Sendable {
    case intrinsicSize
}

public protocol AvatarPickerContentLayoutProviding: Sendable {
    var contentLayout: AvatarPickerContentLayout { get }
}

public enum AvatarPickerContentLayout: String, CaseIterable, Identifiable, AvatarPickerContentLayoutProviding {
    public var contentLayout: AvatarPickerContentLayout { self }

    public var id: Self { self }

    case vertical
    case horizontal
}

public enum AvatarPickerContentLayoutWithPresentation: AvatarPickerContentLayoutProviding, Equatable, Hashable {
    case vertical(presentationStyle: VerticalContentPresentationStyles = .large)
    case horizontal(presentationStyle: HorizontalContentPresentationStyles = .intrinsicSize)

    public var contentLayout: AvatarPickerContentLayout {
        switch self {
        case .horizontal:
            .horizontal
        case .vertical:
            .vertical
        }
    }

    public func hash(into hasher: inout Hasher) {
        switch self {
        case .vertical(presentationStyle: let presentationStyle):
            hasher.combine("vertical")
            switch presentationStyle {
            case .large:
                hasher.combine("large")
            case .extendableMedium(initialFraction: let initialFraction, prioritizeScrollingOverResizing: let prioritizeScrollingOverResizing):
                hasher.combine("extendableMedium")
                hasher.combine(initialFraction)
                hasher.combine(prioritizeScrollingOverResizing)
            }
        case .horizontal(presentationStyle: let presentationStyle):
            hasher.combine("horizontal")
            switch presentationStyle {
            case .intrinsicSize:
                hasher.combine("intrinsicSize")
            }
        }
    }
}
