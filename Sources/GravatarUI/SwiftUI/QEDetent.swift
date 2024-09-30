import Foundation
import SwiftUI

/// SwiftUI and UIKit uses different detent types. This enum allows us to share platform agnostic logic about detents.
enum QEDetent {
    case medium
    case large
    case fraction(CGFloat)
    case height(CGFloat)
    
    static func detents(
        for presentation: AvatarPickerContentLayoutWithPresentation,
        intrinsicHeight: CGFloat,
        verticalSizeClass: UserInterfaceSizeClass?
    ) -> [QEDetent] {
        switch presentation {
        case .horizontal:
            if verticalSizeClass == .compact {
                // in landscape mode where the device height is small we display the full size sheet(which is
                // also the default value of the detent).
                .init([.large])
            } else {
                .init([.height(intrinsicHeight)])
            }
        case .vertical(let presentationStyle):
            switch presentationStyle {
            case .large:
                    .init([.large])
            case .expandableMedium(let initialFraction, _):
                    .init([.fraction(initialFraction), .large])
            }
        }
    }
    
    @MainActor
    func toUISheetDetent() -> UISheetPresentationController.Detent {
        switch self {
        case .large:
            return UISheetPresentationController.Detent.large()
        case .medium:
            return UISheetPresentationController.Detent.medium()
        case .fraction(let value):
            if #available(iOS 16.0, *) {
                return UISheetPresentationController.Detent.custom { context in
                    return value * context.maximumDetentValue
                }
            }
            else {
                return UISheetPresentationController.Detent.medium()
            }
        case .height(let value):
            if #available(iOS 16.0, *) {
                return .custom { _ in value }
            }
            else {
                return .large()
            }
        }
    }
    
    @available(iOS 16.0, *)
    func toSheetDetent() -> PresentationDetent {
        switch self {
        case .large:
            .large
        case .medium:
            .medium
        case .fraction(let value):
            .fraction(value)
        case .height(let height):
            .height(height)
        }
    }
}

extension Array where Element == QEDetent {
    @MainActor
    func map() -> [UISheetPresentationController.Detent] {
        self.map() { element in
            element.toUISheetDetent()
        }
    }
    
    @available(iOS 16.0, *)
    func map() -> Set<PresentationDetent> {
        Set(
            self.map() { element in
                element.toSheetDetent()
            }
        )
    }
}
