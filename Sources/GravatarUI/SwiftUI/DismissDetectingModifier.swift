import Combine
import CoreFoundation
import SwiftUI

struct DismissDetectingModifier: ViewModifier {
    @Binding var dismissAttempt: Bool
    @Binding var isPresented: Bool
    let isLargeDetentOnly: Bool

    @StateObject private var dismissDetectingModel: DismissDetectingModel = .init()

    func body(content: Content) -> some View {
        content
            .onChange(of: isPresented) { newValue in
                if newValue {
                    dismissDetectingModel.reset()
                }
            }
            .onPreferenceChange(VerticalSizeClassPreferenceKey.self) { newSizeClass in
                Task { @MainActor in
                    guard newSizeClass != nil else { return }
                    dismissDetectingModel.reset()
                }
            }
            .background(
                GeometryReader { geo in
                    Color.clear
                        .onChange(of: geo.frame(in: .global)) { newFrame in
                            dismissDetectingModel.viewPosition = newFrame.origin
                        }
                        .onAppear {
                            /// If the sheet only uses .large detent, then SwiftUI doesn't update the layout in a way that triggers
                            /// .onChange(...) initially - it's probably because the frame is resolved immediately and doesn't change afterward.
                            /// If the sheet uses medium or fractional detent, the sheet's frame is not yet finalized in its medium position
                            /// on `onAppear`, so it produces invalid values. Therefore we limit this one to only `[.large]` detents.
                            if isLargeDetentOnly {
                                dismissDetectingModel.viewPosition = geo.frame(in: .global).origin
                            }
                        }
                }
            )
            .onReceive(dismissDetectingModel.$hasBeenDraggedDown.dropFirst().removeDuplicates()) { newValue in
                dismissAttempt = newValue
            }
    }
}

extension DismissDetectingModifier {
    @MainActor
    fileprivate class DismissDetectingModel: ObservableObject {
        @Published var hasBeenDraggedDown = false

        private var initialViewPosition: CGPoint = .zero
        private var lastPosition: CGPoint = .zero
        var viewPosition: CGPoint = .zero {
            didSet {
                viewPositionUpdated()
            }
        }

        private func viewPositionUpdated() {
            let newValue = viewPosition
            if initialViewPosition.y == 0 {
                // store the initial position
                initialViewPosition = newValue
            }
            if hasBeenDraggedDown, newValue.y <= lastPosition.y {
                // the sheet is back up
                setHasBeenDraggedDown(false)
            }
            if (newValue.y - initialViewPosition.y) > 20 {
                // the sheet is dragged down
                setHasBeenDraggedDown(true)
            }
            lastPosition = newValue
        }

        // Resets the internal state. Call it on sheet display, size class change etc.
        func reset() {
            initialViewPosition = .zero
            lastPosition = .zero
        }

        private func setHasBeenDraggedDown(_ value: Bool) {
            // Avoid unnecessary updates.
            if hasBeenDraggedDown != value {
                hasBeenDraggedDown = value
            }
        }
    }
}

extension View {
    func dismissAttemptDetecting(
        dismissAttempt: Binding<Bool>,
        isPresented: Binding<Bool>,
        isLargeDetentOnly: Bool
    ) -> some View {
        modifier(DismissDetectingModifier(
            dismissAttempt: dismissAttempt,
            isPresented: isPresented,
            isLargeDetentOnly: isLargeDetentOnly
        ))
    }
}
