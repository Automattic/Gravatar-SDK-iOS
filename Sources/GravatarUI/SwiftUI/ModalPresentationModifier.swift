import SwiftUI

struct ModalPresentationModifier<ModalView: View>: ViewModifier {
    @Binding var isPresented: Bool
    let modalView: ModalView

    func body(content: Content) -> some View {
        content
            .sheet(isPresented: $isPresented) {
                modalView
            }
    }
}
