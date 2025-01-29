import Foundation
import SwiftUI

/// SwiftUI and UIKit uses different detent types. This enum allows us to share platform agnostic logic about detents.
enum QEDetent {
    case medium
    case large
    case fraction(CGFloat)
    case height(CGFloat)

    static func detents(
        for presentation: AvatarPickerContentLayout,
        intrinsicHeight: CGFloat,
        isEditModeAvatar: Bool,
        verticalSizeClass: UserInterfaceSizeClass?
    ) -> [QEDetent] {
        switch presentation {
        case .horizontal:
            if verticalSizeClass == .compact {
                // in landscape mode where the device height is small we display the full size sheet(which is
                // also the default value of the detent).
                .init([.large])
            } else if !isEditModeAvatar {
                if intrinsicHeight >= QEModalPresentationConstants.bottomSheetEstimatedHeight {
                    .init([.height(intrinsicHeight), .large])
                } else {
                    .init([.fraction(0.7), .large])
                }
                /* if intrinsicHeight > QEModalPresentationConstants.bottomSheetEstimatedHeight {
                     .init([.fraction(0.7), .large])
                 }
                 else {
                    .init([.fraction(0.7), .large])
                    // .init([.height(intrinsicHeight)])
                 }*/
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
    fileprivate func toUISheetDetent() -> UISheetPresentationController.Detent {
        switch self {
        case .large:
            UISheetPresentationController.Detent.large()
        case .medium:
            UISheetPresentationController.Detent.medium()
        case .fraction(let value):
            if #available(iOS 16.0, *) {
                UISheetPresentationController.Detent.custom { context in
                    value * context.maximumDetentValue
                }
            } else {
                UISheetPresentationController.Detent.medium()
            }
        case .height(let value):
            if #available(iOS 16.0, *) {
                .custom { _ in value }
            } else {
                .large()
            }
        }
    }

    @available(iOS 16.0, *)
    fileprivate func toSheetDetent() -> PresentationDetent {
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

extension [QEDetent] {
    @MainActor
    func map() -> [UISheetPresentationController.Detent] {
        self.map { element in
            element.toUISheetDetent()
        }
    }

    @available(iOS 16.0, *)
    func map() -> Set<PresentationDetent> {
        Set(
            self.map { element in
                element.toSheetDetent()
            }
        )
    }
}
