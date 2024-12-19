import SwiftUI
import GravatarUI

struct DemoAvatarPickerView: View {
    @AppStorage("pickerEmail") private var email: String = ""
    @AppStorage("pickerToken") private var token: String = ""
    @AppStorage("pickerContentLayoutOptions") private var contentLayoutOptions: QELayoutOptions = .verticalLarge
    @State private var isSecure: Bool = true

    // You can make this `true` by default to easily test the picker
    @State private var isPresentingPicker: Bool = false
    @State var enableCustomImageCropper: Bool = false
    @State private var selectedScheme: UIUserInterfaceStyle = .unspecified

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            VStack(alignment: .leading, spacing: 5) {
                TextField("Email", text: $email)
                    .font(.callout)
                    .textInputAutocapitalization(.never)
                    .keyboardType(.emailAddress)
                    .disableAutocorrection(true)
                HStack {
                    tokenField()
                        .font(.callout)
                        .textInputAutocapitalization(.never)
                        .disableAutocorrection(true)
                    Button(action: {
                        isSecure.toggle()
                    }) {
                        Image(systemName: isSecure ? "eye.slash" : "eye")
                            .foregroundColor(.gray)
                    }
                }
                Divider()

                QEContentLayoutPickerRow(contentLayoutOptions: $contentLayoutOptions)
                Divider()

                QEColorSchemePickerRow(selectedScheme: $selectedScheme)
                Divider()

                Toggle("Custom image cropper", isOn: $enableCustomImageCropper)
                Spacer()
                    .frame(height: 24)

                Button("Tap to open the Avatar Picker") {
                    isPresentingPicker = true
                }
                .gravatarQuickEditorSheet(
                    isPresented: $isPresentingPicker,
                    email: email,
                    authToken: !token.isEmpty ? token : nil,
                    scope: .avatarPicker(.init(contentLayout: contentLayoutOptions.contentLayout)),
                    customImageEditor: customImageEditor()
                )
                Spacer()
            }
            .padding(.horizontal)
        }
        .preferredColorScheme(ColorScheme(selectedScheme))
    }
    
    func customImageEditor() -> ImageEditorBlock<TestImageCropper>? {
        if enableCustomImageCropper {
            let block = { image, editingDidFinish in
                TestImageCropper(inputImage: image, editingDidFinish: editingDidFinish)
            }
            return block
        }
        return nil as ImageEditorBlock<TestImageCropper>?
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
