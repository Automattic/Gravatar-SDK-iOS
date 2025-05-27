import Combine
import SwiftUI

enum QEModalPresentationConstants {
    // Estimated height for the bottom sheet in horizontal mode.
    // The value is the height of a successfully loading Avatar picker in various iPhone models.
    // This is just the initial value of the bottom sheet. If the content turns out to be
    // smaller or bigger, it'll just adjust.
    static let bottomSheetEstimatedHeight: CGFloat = 538

    // This is the minimum height for the avatar picker bottom sheet in the horizontal mode.
    // This also helps us to ignore insignificant values published by the `InnerHeightPreferenceKey`.
    static let bottomSheetMinHeight: CGFloat = 350
}

struct QuickEditorBottomSheetViewControllerPresentationModifier<QuickEditorPresenter: View>: ViewModifier {
    @Binding var isPresented: Bool

    var quickEditorPresenter: QuickEditorPresenter

    func body(content: Content) -> some View {
        content.if(isPresented) { content in
            ZStack {
                content
                quickEditorPresenter
                    .frame(width: 0, height: 0)
            }
        }
    }
}

@MainActor
protocol ModalPresentationWithIntrinsicSize {
    var scopeOption: QuickEditorScopeOption { get }
    var verticalSizeClass: UserInterfaceSizeClass? { get }
    var shouldPrioritizeScrollOverResize: Bool { get }
}

extension ModalPresentationWithIntrinsicSize {
    func shouldAcceptHeight(_ newHeight: CGFloat) -> Bool {
        newHeight > QEModalPresentationConstants.bottomSheetMinHeight && shouldUseIntrinsicSize
    }

    var shouldUseIntrinsicSize: Bool {
        switch scopeOption.scope {
        case .avatarPicker(let config):
            shouldUseIntrinsicSize(for: config.contentLayout)
        case .aboutInfoEditor(let config):
            switch config.presentationStyle.detentMode {
            case .intrinsicHeight, .automatic:
                true
            case .expandableMedium(_, _), .large:
                false
            }
        case .avatarPickerAndAboutInfoEditor(let config):
            shouldUseIntrinsicSize(for: config.contentLayout)
        }
    }

    func shouldUseIntrinsicSize(for contentLayout: AvatarPickerContentLayout) -> Bool {
        switch contentLayout {
        case .horizontal:
            switch verticalSizeClass {
            case .compact:
                false
            default:
                true
            }
        case .vertical:
            false
        }
    }

    var shouldPrioritizeScrollOverResize: Bool {
        switch scopeOption.scope {
        case .avatarPicker(let config):
            config.contentLayout.prioritizeScrollOverResize
        case .aboutInfoEditor(let config):
            config.presentationStyle.prioritizeScrollOverResize
        case .avatarPickerAndAboutInfoEditor(let config):
            config.contentLayout.prioritizeScrollOverResize
        }
    }
}
