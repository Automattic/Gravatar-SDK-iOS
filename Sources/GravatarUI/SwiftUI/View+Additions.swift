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

    public func avatarPickerSheet(isPresented: Binding<Bool>, email: String, authToken: String, contentLayout: AvatarPickerContentLayout) -> some View {
        let avatarPickerView = AvatarPickerView(model: AvatarPickerViewModel(email: Email(email), authToken: authToken), contentLayout: contentLayout)
        return modifier(ModalPresentationModifier(isPresented: isPresented, modalView: avatarPickerView))
    }

    func avatarPickerBorder(colorScheme: ColorScheme) -> some View {
        self
            .shape(
                RoundedRectangle(cornerRadius: 8),
                borderColor: Color(UIColor.label).opacity(colorScheme == .dark ? 0.16 : 0.08),
                borderWidth: 1
            )
    }
}
