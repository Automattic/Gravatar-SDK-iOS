import SwiftUI
import GravatarUI

struct ContentView: View {
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
    ContentView()
}
