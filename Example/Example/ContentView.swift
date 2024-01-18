import SwiftUI
import Gravatar

struct ContentView: View {
    var body: some View {
        VStack {
            GravatarImage(email: "test@example.com")
            Text("Hello, world!")
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
