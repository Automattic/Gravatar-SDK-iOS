import SwiftUI

struct GravatarNavigationModifier<K: PreferenceKey>: ViewModifier where K.Value == CGFloat {
    var title: String?
    var doneButtonTitle: String?
    var actionButtonDisabled: Bool

    @Environment(\.colorScheme) var colorScheme
    @State private var safariURL: URL?

    var onActionButtonPressed: (() -> Void)? = nil
    var onDoneButtonPressed: (() -> Void)? = nil
    var preferenceKey: K.Type

    func body(content: Content) -> some View {
        content
            .navigationTitle(title ?? GravatarNavigationModifierConstants.gravatarNavigationTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        if let action = onActionButtonPressed {
                            action()
                        } else {
                            openProfileEditInSafari()
                        }
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
                        Text(doneButtonTitle ?? GravatarNavigationModifierConstants.Localized.doneButtonTitle)
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
                        key: preferenceKey,
                        value: geometry.safeAreaInsets.top
                    )
                }
            }
            .presentSafariView(url: $safariURL, colorScheme: colorScheme)
    }

    private func openProfileEditInSafari() {
        guard let url = URL(string: "https://gravatar.com/profile") else { return }
        safariURL = url
    }
}

private enum GravatarNavigationModifierConstants {
    static let gravatarNavigationTitle = "Gravatar"

    enum Localized {
        static let doneButtonTitle = SDKLocalizedString(
            "GravatarNavigationModifier.Button.Done.title",
            value: "Done",
            comment: "Title of a button that closes the current view"
        )
    }
}

extension View {
    func gravatarNavigation<K>(
        title: String? = nil,
        doneButtonTitle: String? = nil,
        actionButtonDisabled: Bool,
        shouldEmitInnerHeight: Bool = true,
        onActionButtonPressed: (() -> Void)? = nil,
        onDoneButtonPressed: (() -> Void)? = nil,
        preferenceKey: K.Type
    ) -> some View where K: PreferenceKey, K.Value == CGFloat {
        modifier(
            GravatarNavigationModifier<K>(
                title: title,
                doneButtonTitle: doneButtonTitle,
                actionButtonDisabled: actionButtonDisabled,
                onActionButtonPressed: onActionButtonPressed,
                onDoneButtonPressed: onDoneButtonPressed,
                preferenceKey: preferenceKey
            )
        )
    }
}
