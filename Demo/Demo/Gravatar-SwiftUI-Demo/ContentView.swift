import SwiftUI
import GravatarUI
import Gravatar

struct ContentView: View {
    @State var model: ProfileCardModel?
    @State var isLoading: Bool = false
    @State var email: String = ""
    @State var error: String? = nil

    var body: some View {
        ScrollView {
            VStack {
                VStack {
                    TextField("Email", text: $email) {
                        getProfile()
                    }.padding()
                    Button("Send") {
                        getProfile()
                    }
                }
                .textFieldStyle(.roundedBorder)
                .keyboardType(.emailAddress)

                if isLoading {
                    VStack {
                        ProgressView()
                    }
                } else {
                    Profile(model: $model).frame(height: 220)
                }
                if let error {
                    Text("Error: \(error)")
                }
            }
            .padding()
            .background(Color(UIColor.secondarySystemBackground))
        }
    }

    func getProfile() {
        error = nil
        Task {
            isLoading = true
            defer { isLoading = false }

            let service = ProfileService()
            do {
                let profile = try await service.fetch(with: .email(email))
                model = profile
            } catch {
                self.error = error.localizedDescription
                print(error.localizedDescription)
            }
        }
    }
}

#Preview {
    ContentView()
}
