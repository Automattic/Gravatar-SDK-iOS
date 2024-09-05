import Combine
import SwiftUI

private enum ModalPresentationConstants {
    // An initial estimated height for the bottom sheet in horizontal mode.
    static let bottomSheetEstimatedHeight: CGFloat = 500
    // This is the minimum height for the sheet in horizontal mode. Helps us to ignore unnecessary height changes.
    static let bottomSheetMinHeight: CGFloat = 350
}

@available(iOS 16.0, *)
struct ModalPresentationModifierWithDetents<ModalView: View>: ViewModifier {
    fileprivate typealias Constants = ModalPresentationConstants
    @Binding var isPresented: Bool
    @State private var isPresentedInner: Bool
    @State private var sheetHeight: CGFloat = Constants.bottomSheetEstimatedHeight
    @State private var verticalSizeClass: UserInterfaceSizeClass?
    @State private var horizontalSizeClass: UserInterfaceSizeClass?
    @State private var presentationDetents: Set<PresentationDetent>
    @State private var prioritizeScrollOverResize: Bool = false
    let onDismiss: (() -> Void)?
    let modalView: ModalView
    var contentLayoutWithPresentation: AvatarPickerContentLayoutWithPresentation

    init(isPresented: Binding<Bool>, onDismiss: (() -> Void)? = nil, modalView: ModalView, contentLayout: AvatarPickerContentLayoutWithPresentation) {
        self._isPresented = isPresented
        self.isPresentedInner = isPresented.wrappedValue
        self.onDismiss = onDismiss
        self.modalView = modalView
        self.contentLayoutWithPresentation = contentLayout
        self.presentationDetents = Self.detents(
            for: contentLayout,
            intrinsicHeight: Constants.bottomSheetEstimatedHeight,
            verticalSizeClass: nil,
            horizontalSizeClass: nil
        )
    }

    private static func detents(
        for presentation: AvatarPickerContentLayoutWithPresentation,
        intrinsicHeight: CGFloat,
        verticalSizeClass: UserInterfaceSizeClass?,
        horizontalSizeClass: UserInterfaceSizeClass?
    ) -> Set<PresentationDetent> {
        switch presentation {
        case .horizontal:
            if verticalSizeClass == .compact || (horizontalSizeClass != nil && horizontalSizeClass != .compact) {
                // in landscape mode where the device height is small we display the full size sheet(which is
                // also the default value of the detent).
                // similarly in large devices like iPads, we display it the default way and not try to
                // show it with intrinsic height. The system ignores it anyway.
                .init([.large])
            } else {
                .init([.height(intrinsicHeight)])
            }
        case .vertical(let presentationStyle):
            switch presentationStyle {
            case .large:
                .init([.large])
            case .extendableMedium(let initialFraction, _):
                .init([.fraction(initialFraction), .large])
            }
        }
    }

    private func updateDetents() {
        self.presentationDetents = Self.detents(
            for: contentLayoutWithPresentation,
            intrinsicHeight: sheetHeight,
            verticalSizeClass: verticalSizeClass,
            horizontalSizeClass: horizontalSizeClass
        )
        switch contentLayoutWithPresentation {
        case .vertical(let presentationStyle):
            switch presentationStyle {
            case .large:
                break
            case .extendableMedium(_, let prioritizeScrollOverResize):
                self.prioritizeScrollOverResize = prioritizeScrollOverResize
            }
        case .horizontal:
            prioritizeScrollOverResize = true
        }
    }

    private var shouldUseIntrinsicSize: Bool {
        switch contentLayoutWithPresentation {
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

    func body(content: Content) -> some View {
        content
            .onChange(of: isPresented) { newValue in
                if newValue {
                    // First init the detents and then present. This helps with starting off with the correct state.
                    // Otherwise the view remembers its previous height. And an animation glitch happens
                    // when switching between different presentation styles (especially between horizontal and vertical_large).
                    // Doing the same thing in .onAppear of the "modalView" doesn't give as nice results as this one don't know why.
                    self.presentationDetents = Self.detents(
                        for: contentLayoutWithPresentation,
                        intrinsicHeight: max(sheetHeight, Constants.bottomSheetEstimatedHeight),
                        verticalSizeClass: verticalSizeClass,
                        horizontalSizeClass: horizontalSizeClass
                    )
                }
                isPresentedInner = newValue
            }
            .onChange(of: isPresentedInner) { newValue in
                self.isPresented = newValue
            }
            .sheet(isPresented: $isPresentedInner, onDismiss: onDismiss) {
                modalView
                    .if(shouldUseIntrinsicSize) { view in
                        view
                            .frame(minHeight: Constants.bottomSheetMinHeight)
                    }
                    .onPreferenceChange(InnerHeightPreferenceKey.self) { newHeight in
                        if newHeight > Constants.bottomSheetMinHeight, shouldUseIntrinsicSize {
                            sheetHeight = newHeight
                        }
                        updateDetents()
                    }
                    .onPreferenceChange(VerticalSizeClassPreferenceKey.self) { newSizeClass in
                        guard newSizeClass != nil else { return }
                        self.verticalSizeClass = newSizeClass
                        updateDetents()
                    }
                    .onPreferenceChange(HorizontalSizeClassPreferenceKey.self) { newSizeClass in
                        guard newSizeClass != nil else { return }
                        self.horizontalSizeClass = newSizeClass
                        updateDetents()
                    }
                    .presentationDetents(presentationDetents)
                    .presentationContentInteraction(shouldPrioritizeScrolling: prioritizeScrollOverResize)
            }
    }
}
