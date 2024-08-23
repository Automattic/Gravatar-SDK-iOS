import SwiftUI

struct GravatarNavigationModifier: ViewModifier {
    @State var title: String
    @Binding var actionButtonDisabled: Bool

    var onActionButtonPressed: (() -> Void)? = nil
    var onDoneButtonPressed: (() -> Void)? = nil

    func body(content: Content) -> some View {
        content
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        onActionButtonPressed?()
                    }) {
                        Image("gravatar", bundle: .module)
                            .tint(Color(UIColor.gravatarBlue))
                    }
                    .disabled(actionButtonDisabled)
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        onDoneButtonPressed?()
                    }) {
                        Text("Done")
                            .tint(Color(UIColor.gravatarBlue))
                    }
                }
            }
    }
}

extension View {
    func gravatarNavigation(
        title: String,
        actionButtonDisabled: Binding<Bool>,
        onActionButtonPressed: (() -> Void)? = nil,
        onDoneButtonPressed: (() -> Void)? = nil
    ) -> some View {
        modifier(
            GravatarNavigationModifier(
                title: title,
                actionButtonDisabled: actionButtonDisabled,
                onActionButtonPressed: onActionButtonPressed,
                onDoneButtonPressed: onDoneButtonPressed
            )
        )
    }
}
