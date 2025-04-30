import SwiftUI

struct ModalPresentationModifier<ModalView: View>: ViewModifier {
    @Binding var isPresented: Bool
    @Environment(\.colorScheme) var colorScheme: ColorScheme
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
                    .preferredColorScheme(colorScheme)
            }
    }
}

struct ModalItemPresentationModifier<ModalView: View, T>: ViewModifier where T: Identifiable {
    @Binding var item: T?

    let onDismiss: (() -> Void)?
    let modalViewBuilder: (T) -> ModalView

    init(item: Binding<T?>, onDismiss: (() -> Void)? = nil, @ViewBuilder modalView: @escaping (T) -> ModalView) {
        self._item = item
        self.onDismiss = onDismiss
        self.modalViewBuilder = modalView
    }

    func body(content: Content) -> some View {
        content
            .sheet(item: $item) { item in
                modalViewBuilder(item)
            }
    }
}
