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
                    dismissDetectingModel.reset(isLargeDetentOnly: isLargeDetentOnly)
                }
            }
            .onPreferenceChange(VerticalSizeClassPreferenceKey.self) { newSizeClass in
                Task { @MainActor in
                    guard newSizeClass != nil else { return }
                    dismissDetectingModel.reset(isLargeDetentOnly: isLargeDetentOnly)
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
            .onReceive(dismissDetectingModel.$hasBeenBouncedBack.dropFirst().removeDuplicates()) { newValue in
                dismissAttempt = newValue
            }
    }
}

extension DismissDetectingModifier {
    enum DragDirection {
        case up
        case down
    }

    @MainActor
    fileprivate class DismissDetectingModel: ObservableObject {
        private static let threshold: CGFloat = 20
        /// Apply this threshold to avoid large to medium detent changes where dragging down does not mean closing.
        private static let largeDetentThreshold: CGFloat = 100
        @Published private(set) var hasBeenBouncedBack = false

        private var lastPosition: CGPoint = .zero
        private var dragDirection: DragDirection = .down
        private var positionOnDirectionChange: CGPoint = .zero
        var isLargeDetentOnly: Bool = false
        var viewPosition: CGPoint = .zero {
            didSet {
                viewPositionUpdated()
            }
        }

        private func viewPositionUpdated() {
            let newValue = viewPosition
            if newValue.y <= lastPosition.y {
                if dragDirection == .down {
                    positionOnDirectionChange = newValue
                }
                dragDirection = .up

                if newValue.y - positionOnDirectionChange.y == 0,
                   isLargeDetentOnly || (!isLargeDetentOnly && newValue.y > Self.largeDetentThreshold)
                {
                    setHasBeenBouncedBack(true)
                }
            } else {
                if dragDirection == .up {
                    positionOnDirectionChange = newValue
                }
                dragDirection = .down
                if (newValue.y - positionOnDirectionChange.y) > Self.threshold,
                   isLargeDetentOnly || (!isLargeDetentOnly && newValue.y > Self.largeDetentThreshold)
                {
                    setHasBeenBouncedBack(false)
                }
            }

            lastPosition = newValue
        }

        // Resets the internal state. Call it on sheet display, size class change etc.
        func reset(isLargeDetentOnly: Bool) {
            positionOnDirectionChange = .zero
            lastPosition = .zero
            self.isLargeDetentOnly = isLargeDetentOnly
        }

        private func setHasBeenBouncedBack(_ value: Bool) {
            // Avoid unnecessary updates.
            if hasBeenBouncedBack != value {
                hasBeenBouncedBack = value
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
