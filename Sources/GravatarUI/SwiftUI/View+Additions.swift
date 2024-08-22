import SwiftUI

@MainActor
extension View {
    public func shape(_ shape: some Shape, borderColor: Color = .clear, borderWidth: CGFloat = 0) -> some View {
        self
            .clipShape(shape)
            .overlay(
                shape
                    .stroke(borderColor, lineWidth: borderWidth)
            )
    }

    public func avatarPickerSheet(isPresented: Binding<Bool>, email: String, authToken: String) -> some View {
        let avatarPickerView = AvatarPickerView(model: AvatarPickerViewModel(email: Email(email), authToken: authToken))
        return modifier(ModalPresentationModifier(isPresented: isPresented, modalView: avatarPickerView))
    }
}

@MainActor
extension View {
    public func gravatarEditorSheet(isPresented: Binding<Bool>, email: String, entryPoint: ProfileEditorEntryPoint, onDismiss: (() -> Void)? = nil) -> some View {
        let editor = ProfileEditor(email: .init(email), entryPoint: entryPoint)
        return modifier(ModalPresentationModifier(isPresented: isPresented, onDismiss: onDismiss, modalView: editor))
    }
}

