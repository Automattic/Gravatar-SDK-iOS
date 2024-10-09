import Foundation
import GravatarUI

enum QELayoutOptions: String, Identifiable, CaseIterable {
    var id: String { rawValue }
    
    case verticalLarge = "vertical - large"
    case verticalExpandable = "vertical - expandable"
    case verticalExpandablePrioritizeScrolling = "vertical - expandable - prioritize scrolling"
    case horizontal = "horizontal"
    
    var contentLayout: AvatarPickerContentLayout {
        switch self {
        case .verticalLarge:
                .vertical(presentationStyle: .large)
        case .verticalExpandable:
                .vertical(presentationStyle: .expandableMedium())
        case .verticalExpandablePrioritizeScrolling:
                .vertical(presentationStyle: .expandableMedium(prioritizeScrollOverResize: true))
        case .horizontal:
                .horizontal()
        }
    }
}
