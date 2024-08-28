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

    public func avatarPickerSheet(
        isPresented: Binding<Bool>,
        email: String,
        authToken: String,
        contentLayout: AvatarPickerContentLayout,
        customImageEditor: ImageEditorBlock<some ImageEditorView>? = nil as NoCustomEditorBlock?
    ) -> some View {
        let avatarPickerView = AvatarPickerView(
            model: AvatarPickerViewModel(email: Email(email), authToken: authToken),
            contentLayout: contentLayout,
            isPresented: isPresented,
            customImageEditor: customImageEditor
        )
        let navigationWrapped = NavigationView { avatarPickerView }
        return modifier(ModalPresentationModifier(isPresented: isPresented, modalView: navigationWrapped))
    }

    func avatarPickerBorder(colorScheme: ColorScheme, borderWidth: CGFloat = 1) -> some View {
        self
            .shape(
                RoundedRectangle(cornerRadius: 8),
                borderColor: Color(UIColor.label).opacity(colorScheme == .dark ? 0.16 : 0.08),
                borderWidth: borderWidth
            )
            .padding(.vertical, borderWidth) // to prevent borders from getting clipped
    }

    public func gravatarQuickEditorSheet(
        isPresented: Binding<Bool>,
        email: String,
        scope: QuickEditorScope,
        customImageEditor: ImageEditorBlock<some ImageEditorView>? = nil as NoCustomEditorBlock?,
        onDismiss: (() -> Void)? = nil
    ) -> some View {
        let editor = QuickEditor(email: .init(email), scope: scope, isPresented: isPresented, customImageEditor: customImageEditor)
        return modifier(ModalPresentationModifier(isPresented: isPresented, onDismiss: onDismiss, modalView: editor))
    }
}
