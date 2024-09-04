import SwiftUI
import Combine

fileprivate enum ModalPresentationConstants {
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
    @State var verticalSizeClass: UserInterfaceSizeClass?
    @State var horizontalSizeClass: UserInterfaceSizeClass?
    @State private var presentationDetents: Set<PresentationDetent>
    @State private var prioritizeScrollingOverResizing: Bool = false
    let onDismiss: (() -> Void)?
    let modalView: ModalView
    var contentLayoutWithPresentation: AvatarPickerContentLayoutWithPresentation

    init(isPresented: Binding<Bool>, onDismiss: (() -> Void)? = nil, modalView: ModalView, contentLayout: AvatarPickerContentLayoutWithPresentation) {
        self._isPresented = isPresented
        self.isPresentedInner = isPresented.wrappedValue
        self.onDismiss = onDismiss
        self.modalView = modalView
        self.contentLayoutWithPresentation = contentLayout
        self.presentationDetents = Self.detents(for: contentLayout, intrinsicHeight: Constants.bottomSheetEstimatedHeight, verticalSizeClass: nil, horizontalSizeClass: nil)
    }
    
    private static func detents(for presentation: AvatarPickerContentLayoutWithPresentation, intrinsicHeight: CGFloat, verticalSizeClass: UserInterfaceSizeClass?, horizontalSizeClass: UserInterfaceSizeClass?) -> Set<PresentationDetent> {
        switch presentation {
        case .horizontal:
            if verticalSizeClass == .compact || (horizontalSizeClass != nil && horizontalSizeClass != .compact) {
                // in landscape mode where the device height is small we display the full size sheet(which is
                // also the default value of the detent).
                // similarly in large devices like iPads, we display it the default way and not try to
                // show it with intrinsic height. The system ignores it anyway.
                return .init([.large])
            }
            else {
                return .init([.height(intrinsicHeight)])
            }
        case .vertical(let presentationStyle):
            switch presentationStyle {
            case .large:
                return .init([.large])
            case let .extendableMedium(initialFraction, _):
                return .init([.fraction(initialFraction), .large])
            }
        }
    }

    private func updateDetents() {
        self.presentationDetents = Self.detents(for: contentLayoutWithPresentation, intrinsicHeight: sheetHeight, verticalSizeClass: verticalSizeClass, horizontalSizeClass: horizontalSizeClass)
        switch contentLayoutWithPresentation {
        case .vertical(let presentationStyle):
            switch presentationStyle {
            case .large:
                break
            case let .extendableMedium(_, prioritizeScrollingOverResizing):
                self.prioritizeScrollingOverResizing = prioritizeScrollingOverResizing
            }
        case .horizontal:
            prioritizeScrollingOverResizing = true
        }
    }
    
    private var shouldUseIntrinsicSize: Bool {
        switch contentLayoutWithPresentation {
        case .horizontal:
            switch verticalSizeClass {
            case .compact:
                return false
            default:
                return true
            }
        case .vertical:
            return false
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
                    self.presentationDetents = Self.detents(for: contentLayoutWithPresentation, intrinsicHeight: max(sheetHeight, Constants.bottomSheetEstimatedHeight), verticalSizeClass: verticalSizeClass, horizontalSizeClass: horizontalSizeClass)
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
                    .presentationContentInteraction(shouldPrioritizeScrolling: prioritizeScrollingOverResizing)
            }
    }
}

struct InnerHeightPreferenceKey: PreferenceKey {
    static let defaultValue: CGFloat = .zero
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value += nextValue()
    }
}

protocol ValueAccumulatingPreferenceKey: PreferenceKey { }

extension ValueAccumulatingPreferenceKey {
    static func reduce(value: inout UserInterfaceSizeClass?, nextValue: () -> UserInterfaceSizeClass?) {
        let next = nextValue()
        if value == nil {
            value = next
        }
    }
}

struct VerticalSizeClassPreferenceKey: ValueAccumulatingPreferenceKey {
    static let defaultValue: UserInterfaceSizeClass? = nil
}

struct HorizontalSizeClassPreferenceKey: ValueAccumulatingPreferenceKey {
    static let defaultValue: UserInterfaceSizeClass? = nil
}
