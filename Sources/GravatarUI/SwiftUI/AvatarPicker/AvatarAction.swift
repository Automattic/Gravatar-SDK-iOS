import Foundation
import SwiftUI

enum AvatarAction: String, CaseIterable, Identifiable {
    case share
    case delete

    var id: String { rawValue }

    var icon: Image {
        switch self {
        case .delete:
            Image(systemName: "trash")
        case .share:
            Image(systemName: "square.and.arrow.up")
        }
    }

    var localizedTitle: String {
        switch self {
        case .delete:
            SDKLocalizedString(
                "AvatarPicker.AvatarAction.delete",
                value: "Delete",
                comment: "An option in the avatar menu that deletes the avatar"
            )
        case .share:
            SDKLocalizedString(
                "AvatarPicker.AvatarAction.share",
                value: "Share",
                comment: "An option in the avatar menu that shares the avatar"
            )
        }
    }

    var role: ButtonRole? {
        switch self {
        case .delete:
            .destructive
        case .share:
            nil
        }
    }
}
