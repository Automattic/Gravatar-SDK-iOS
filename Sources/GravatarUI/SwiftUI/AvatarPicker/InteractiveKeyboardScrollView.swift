import SwiftUI

@MainActor
struct InteractiveKeyboardScrollView<Content: View>: View {
    @ViewBuilder let content: () -> Content

    var body: some View {
        if #available(iOS 16.0, *) {
            ScrollView {
                content()
            }
            .scrollDismissesKeyboard(.interactively)
        } else {
            ScrollView {
                content()
            }
        }
    }
}
