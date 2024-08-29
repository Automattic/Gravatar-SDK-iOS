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

@available(iOS 16.0, *)
struct ModalPresentationModifierWithDetents<ModalView: View>: ViewModifier {
    @Binding var isPresented: Bool
    let onDismiss: (() -> Void)?
    let modalView: ModalView
    let presentationDetents: Set<PresentationDetent>

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
                    .presentationDetents(presentationDetents)
            }
    }
}
