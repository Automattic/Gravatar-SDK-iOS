import SwiftUI
import GravatarUI

@MainActor
struct DemoAvatarPickerView: View {
    
    @AppStorage("pickerEmail") private var email: String = ""
    @AppStorage("pickerToken") private var token: String = ""
    @State private var isSecure: Bool = true
    @StateObject private var avatarPickerModel = AvatarPickerViewModel(email: .init(""), authToken: "")
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            VStack(alignment: .leading, spacing: 5) {
                TextField("Email", text: $email)
                    .font(.callout)
                    .textInputAutocapitalization(.never)
                    .keyboardType(.emailAddress)
                    .disableAutocorrection(true)
                    .onChange(of: email) { oldValue, newValue in
                        avatarPickerModel.update(email: email)
                    }
                HStack {
                    tokenField()
                        .font(.callout)
                        .textInputAutocapitalization(.never)
                        .disableAutocorrection(true)
                        .onChange(of: token) { oldValue, newValue in
                            avatarPickerModel.update(authToken: token)
                        }
                    Button(action: {
                        isSecure.toggle()
                    }) {
                        Image(systemName: isSecure ? "eye.slash" : "eye")
                            .foregroundColor(.gray)
                    }
                }
                Divider()
            }
            .padding(.horizontal)
            
            AvatarPickerView(model: avatarPickerModel).onAppear() {
                avatarPickerModel.update(email: email)
                avatarPickerModel.update(authToken: token)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
    
    @ViewBuilder
    func tokenField() -> some View {
        if isSecure {
            SecureField("Token", text: $token)
        } else {
            TextField("Token", text: $token)
        }
    }
}

#Preview {
    DemoAvatarPickerView()
}
