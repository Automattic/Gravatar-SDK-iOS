import SwiftUI
import GravatarUI

struct DemoProfileEditorView: View {

    @AppStorage("pickerEmail") private var email: String = ""

    // You can make this `true` by default to easily test the picker
    @State private var isPresentingPicker: Bool = false

    var body: some View {
        VStack(spacing: 20) {
            VStack(alignment: .leading, spacing: 5) {
                TextField("Email", text: $email)
                    .font(.callout)
                    .textInputAutocapitalization(.never)
                    .keyboardType(.emailAddress)
                    .disableAutocorrection(true)

                Divider()

            }
            .padding(.horizontal)
            Button("Open Profile Editor with OAuth flow") {
                isPresentingPicker.toggle()
            }
            .gravatarEditorSheet(isPresented: $isPresentingPicker, email: email, entryPoint: .avatarPicker)
            Spacer()
        }
    }
}

#Preview {
    DemoAvatarPickerView()
}
