import Gravatar
import SwiftUI

@MainActor
extension View {
    func shape(_ shape: some Shape, borderColor: Color = .clear, borderWidth: CGFloat = 0) -> some View {
        self
            .clipShape(shape)
            .overlay(
                shape
                    .stroke(borderColor, lineWidth: borderWidth)
            )
    }

    func avatarPickerSheet(isPresented: Binding<Bool>, email: String, authToken: String) -> some View {
        let avatarPickerView = AvatarPickerView(model: AvatarPickerViewModel(email: Email(email), authToken: authToken))
        return modifier(ModalPresentationModifier(isPresented: isPresented, modalView: avatarPickerView))
    }
}
