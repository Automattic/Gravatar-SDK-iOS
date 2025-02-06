import SwiftUI
import GravatarUI

struct ContentView: View {
    let onDismiss: (() -> Void)?

    enum Page: String, CaseIterable, Identifiable {
        case avatarView = "Avatar view"
        case avatarPickerView = "Avatar picker view"
        case oauth = "Profile editor with oauth"

        var id: Int {
            self.rawValue.hashValue
        }
        
        var title: String {
            rawValue
        }
    }

    var body: some View {
        if #available(iOS 16.0, *) {
            NavigationStack {
                List(Page.allCases) { page in
                    NavigationLink(page.title, value: page)
                }
                .listStyle(.plain)
                .navigationDestination(for: Page.self) { value in
                    pageView(for: value).navigationTitle(value.title)
                }
                .navigationTitle("Gravatar SwiftUI Demo")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar<DemoToolbarContentView> {
                    DemoToolbarContentView(onDismiss: onDismiss)
                }
            }
        } else {
            NavigationView {
                List(Page.allCases) { page in
                    NavigationLink {
                        pageView(for: page)
                    } label: {
                        Text(page.title)
                    }
                }
                .listStyle(.plain)
                .navigationTitle("Gravatar SwiftUI Demo")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar<DemoToolbarContentView> {
                    DemoToolbarContentView(onDismiss: onDismiss)
                }
            }
        }
    }

    @ViewBuilder
    func pageView(for page: Page) -> some View {
        switch page {
        case .avatarView:
            DemoAvatarView()
        case .avatarPickerView:
            DemoAvatarPickerView()
        case .oauth:
            DemoProfileEditorView()
        }
    }
}

#Preview {
    ContentView(onDismiss: nil)
}

struct DemoToolbarContentView: ToolbarContent {
    let onDismiss: (() -> Void)?

    @ToolbarContentBuilder @MainActor @preconcurrency var body: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            Button("Dismiss") {
                onDismiss?()
            }
        }
    }
}
