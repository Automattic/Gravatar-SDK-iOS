import SwiftUI
import Combine

fileprivate enum ModalPresentationConstants {
    static let bottomSheetEstimatedMinHeight: CGFloat = 500
}

@available(iOS 16.0, *)
struct ModalPresentationModifierWithDetents<ModalView: View>: ViewModifier {
    fileprivate typealias Constants = ModalPresentationConstants
    @Binding var isPresented: Bool
    @State private var isPresentedInner: Bool
    @State private var sheetHeight: CGFloat = Constants.bottomSheetEstimatedMinHeight
    @State var verticalSizeClass: UserInterfaceSizeClass?
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
        self.presentationDetents = Self.detents(for: contentLayout, intrinsicHeight: Constants.bottomSheetEstimatedMinHeight, verticalSizeClass: nil)
    }
    
    private static func detents(for presentation: AvatarPickerContentLayoutWithPresentation, intrinsicHeight: CGFloat, verticalSizeClass: UserInterfaceSizeClass?) -> Set<PresentationDetent> {
        switch presentation {
        case .horizontal:
            switch verticalSizeClass {
            case .compact:
                // in landscape mode where the device height is small we display the full size sheet(which is
                // also the default value of the detent).
                return .init([.large])
            default:
                // otherwise use intrinsic height
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
        self.presentationDetents = Self.detents(for: contentLayoutWithPresentation, intrinsicHeight: sheetHeight, verticalSizeClass: verticalSizeClass)
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
                    self.presentationDetents = Self.detents(for: contentLayoutWithPresentation, intrinsicHeight: sheetHeight, verticalSizeClass: verticalSizeClass)
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
                            .frame(minHeight: Constants.bottomSheetEstimatedMinHeight)
                    }
                    .onPreferenceChange(InnerHeightPreferenceKey.self) { newHeight in
                        if newHeight > Constants.bottomSheetEstimatedMinHeight, shouldUseIntrinsicSize {
                            sheetHeight = newHeight
                        }
                        updateDetents()
                    }
                    .onPreferenceChange(SizeClassPreferenceKey.self) { newSizeClass in
                        guard newSizeClass != nil else { return }
                        self.verticalSizeClass = newSizeClass
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

struct SizeClassPreferenceKey: PreferenceKey {
    static let defaultValue: UserInterfaceSizeClass? = nil
    static func reduce(value: inout UserInterfaceSizeClass?, nextValue: () -> UserInterfaceSizeClass?) {
        let next = nextValue()
        if value == nil {
            value = next
        }
    }
}
