import SwiftUI

struct GravatarNavigationModifier: ViewModifier {
    var title: String
    var actionButtonDisabled: Bool

    var onActionButtonPressed: (() -> Void)? = nil
    var onDoneButtonPressed: (() -> Void)? = nil
    @State var navBarHeight: CGFloat = .zero

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
            .background {
                GeometryReader { geometry in
                    // Interesting but this works to detect the navigation bar height.
                    // AFAIU, SwiftUI calculates the safeAreaInsets.top based on the actual visible content area.
                    // When a NavigationView is present, it accounts for the navigation bar being part of that system-provided safe area.
                    Color.clear.preference(
                        key: InnerHeightPreferenceKey.self,
                        value: geometry.safeAreaInsets.top
                    )
                }
            }
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
