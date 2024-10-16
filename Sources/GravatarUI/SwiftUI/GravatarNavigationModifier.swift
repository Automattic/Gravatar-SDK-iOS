import SwiftUI

struct GravatarNavigationModifier: ViewModifier {
    var title: String
    var actionButtonDisabled: Bool

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
                        Text(Localized.doneButtonTitle)
                            .tint(Color(UIColor.gravatarBlue))
                    }
                }
            }
            .background {
                GeometryReader { geometry in
                    // This works to detect the navigation bar height.
                    // AFAIU, SwiftUI calculates the `safeAreaInsets.top` based on the actual visible content area.
                    // When a NavigationView is present, it accounts for the navigation bar being part of that system-provided safe area.
                    Color.clear.preference(
                        key: InnerHeightPreferenceKey.self,
                        value: geometry.safeAreaInsets.top
                    )
                }
            }
    }
}

extension GravatarNavigationModifier {
    private enum Localized {
        static let doneButtonTitle = SDKLocalizedString(
            "GravatarNavigationModifier.Button.Done.title",
            value: "Done",
            comment: "Title of a button that closes the current view"
        )
    }
}

extension View {
    func gravatarNavigation(
        title: String,
        actionButtonDisabled: Bool,
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
