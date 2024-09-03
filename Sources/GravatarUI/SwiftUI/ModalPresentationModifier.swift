import SwiftUI

struct ModalPresentationModifier<ModalView: View>: ViewModifier {
    @Binding var isPresented: Bool
    let onDismiss: (() -> Void)?
    let modalView: ModalView

    init(isPresented: Binding<Bool>, onDismiss: (() -> Void)? = nil, modalView: ModalView) {
        self._isPresented = isPresented
        self.onDismiss = onDismiss
        self.modalView = modalView
    }

    func body(content: Content) -> some View {
        content
            .sheet(isPresented: $isPresented, onDismiss: onDismiss) {
                modalView
            }
    }
}

@available(iOS 16.4, *)
struct ModalPresentationModifierWithDetents<ModalView: View>: ViewModifier {
    @Binding var isPresented: Bool
    let onDismiss: (() -> Void)?
    let modalView: ModalView
    let presentationDetents: Set<PresentationDetent>
    @State private var sheetHeight: CGFloat = .zero
    //@State private var isGeomeryReaderVisible: Bool = false

    init(isPresented: Binding<Bool>, onDismiss: (() -> Void)? = nil, modalView: ModalView, presentationDetents: Set<PresentationDetent>) {
        self._isPresented = isPresented
        self.onDismiss = onDismiss
        self.modalView = modalView
        self.presentationDetents = presentationDetents
    }

    func body(content: Content) -> some View {
        content
            .sheet(isPresented: $isPresented, onDismiss: onDismiss) {
                modalView
                    .onPreferenceChange(InnerHeightPreferenceKey.self) { newHeight in
                        print("newHeight: \(newHeight)")
                        sheetHeight = newHeight
                    }
                  /* .overlay {
                       if isGeomeryReaderVisible {
                           GeometryReader { geometry in
                               Color.clear.preference(key: InnerHeightPreferenceKey.self, value: geometry.size.height)
                           }
                       }
                    }
                    .onPreferenceChange(InnerHeightPreferenceKey.self) { newHeight in
                        print("newHeight: \(newHeight)")
                        sheetHeight = newHeight
                    }
                    .onAppear() {
                        isGeomeryReaderVisible = true
                    }*/
                    .presentationDetents([.height(sheetHeight)])
                    .presentationContentInteraction(.scrolls)
                
            }
    }
}
/**
 Vertical scrolling presentation modes:
 - .large
 - .large, .fraction(0.7)  scrolling makes the sheet larger first
 - .large, .fraction(0.7)  scrolling just scrolls the content
 */

/**
 Horizontal scrolling presentation modes:
- 
 */

struct InnerHeightPreferenceKey: PreferenceKey {
    static let defaultValue: CGFloat = .zero
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
      //  print("value before: \(value)")
        value += nextValue()
      //  print("value after: \(value)")
    }
}
