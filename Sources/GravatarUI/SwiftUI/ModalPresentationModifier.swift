import SwiftUI

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
