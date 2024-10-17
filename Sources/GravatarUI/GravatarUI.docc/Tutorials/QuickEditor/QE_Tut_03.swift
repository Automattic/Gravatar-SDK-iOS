import GravatarUI
import SwiftUI

struct ContentView: View {
    @AppStorage("pickerEmail") private var email: String = ""
    @AppStorage("pickAuthToken") private var authToken: String = ""
    @State private var isPresentingPicker: Bool = false
    
    var body: some View {
        VStack {
            VStack {
                TextField("Enter your email", text: $email)
                    .font(.callout)
                    .textInputAutocapitalization(.never)
                    .keyboardType(.emailAddress)
                    .disableAutocorrection(true)
                SecureField("Enter your auth token", text: $authToken)
                    .font(.callout)
                    .textInputAutocapitalization(.never)
                    .disableAutocorrection(true)
            }
            .padding(20)
            
            Button("Show Quick Editor") {
                isPresentingPicker = true
            }
            .gravatarQuickEditorSheet(
                isPresented: $isPresentingPicker,
                email: email,
                authToken: authToken,
                scope: .avatarPicker(.verticalLarge)
            )
            
            Spacer()
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
