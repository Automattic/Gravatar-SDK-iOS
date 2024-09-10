import Combine
import SwiftUI

private enum ModalPresentationConstants {
    // Estimated height for the bottom sheet in horizontal mode.
    // The value is the height of a successfully loading Avatar picker in various iPhone models.
    // This is just the initial value of the bottom sheet. If the content turns out to be
    // smaller or bigger, it'll just adjust.
    static let bottomSheetEstimatedHeight: CGFloat = 538

    // This is the minimum height for the avatar picker bottom sheet in the horizontal mode.
    // This also helps us to ignore insignificant values published by the `InnerHeightPreferenceKey`.
    static let bottomSheetMinHeight: CGFloat = 350
}

@available(iOS 16.0, *)
struct AvatarPickerModalPresentationModifier<ModalView: View>: ViewModifier {
    fileprivate typealias Constants = ModalPresentationConstants
    @Binding var isPresented: Bool
    @State private var isPresentedInner: Bool
    @State private var sheetHeight: CGFloat = Constants.bottomSheetEstimatedHeight
    @State private var verticalSizeClass: UserInterfaceSizeClass?
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
            verticalSizeClass: nil
        )
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
                        verticalSizeClass: verticalSizeClass
                    )
                }
                isPresentedInner = newValue
            }
            .onChange(of: isPresentedInner) { newValue in
                self.isPresented = newValue
            }
            .sheet(isPresented: $isPresentedInner, onDismiss: onDismiss) {
                modalView
                    .frame(minHeight: Constants.bottomSheetMinHeight)
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
                    .presentationDetents(presentationDetents)
                    .presentationContentInteraction(shouldPrioritizeScrolling: prioritizeScrollOverResize)
            }
    }

    private static func detents(
        for presentation: AvatarPickerContentLayoutWithPresentation,
        intrinsicHeight: CGFloat,
        verticalSizeClass: UserInterfaceSizeClass?
    ) -> Set<PresentationDetent> {
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

    private func updateDetents() {
        self.presentationDetents = Self.detents(
            for: contentLayoutWithPresentation,
            intrinsicHeight: sheetHeight,
            verticalSizeClass: verticalSizeClass
        )
        switch contentLayoutWithPresentation {
        case .vertical(let presentationStyle):
            switch presentationStyle {
            case .large:
                break
            case .expandableMedium(_, let prioritizeScrollOverResize):
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
}
