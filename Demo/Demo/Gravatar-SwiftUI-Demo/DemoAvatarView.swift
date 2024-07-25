import SwiftUI
@testable import GravatarUI

struct DemoAvatarView: View {
    enum Constants {
        static let avatarSize = CGSize(width: 120, height: 120)
        static let borderWidth: CGFloat = 2
    }
    
    @AppStorage("email") private var email: String = ""
    @State var borderWidthDouble: Double? = Constants.borderWidth
    @State var cornerRadiusDouble: Double? = 8

    @State var borderWidth: CGFloat = Constants.borderWidth
    @State var forceRefresh: Bool = false
    @State var isAnimated: Bool = true
    @State var borderColor: Color = .purple

    var avatarURL: AvatarURL? {
        AvatarURL(
            with: .email(email),
            options: .init(
                preferredSize: .points(Constants.avatarSize.width),
                defaultAvatarOption: .status404
            )
        )
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 0) {
                    Text("Email:").font(.caption2).foregroundStyle(.secondary)
                    TextField("Email", text: $email)
                        .textInputAutocapitalization(.never)
                        .keyboardType(.emailAddress)
                        .disableAutocorrection(true)
                }
                StepperField(title: "Border width", value: $borderWidthDouble)
                StepperField(title: "Corner radius", value: $cornerRadiusDouble)
                ColorPicker("Border color", selection: $borderColor)
                Toggle("Force refresh", isOn: $forceRefresh)
                Toggle("Animated", isOn: $isAnimated)
                Divider()
                AvatarView(
                    url: avatarURL?.url,
                    placeholder: Image("profileAvatar").renderingMode(.template),
                    forceRefresh: $forceRefresh,
                    loadingView: {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                    },
                    transaction: Transaction(animation: isAnimated ? .easeInOut(duration: 0.3) : nil)
                )
                .shape(RoundedRectangle(cornerRadius: CGFloat(cornerRadiusDouble ?? 0)),
                       borderColor: borderColor,
                       borderWidth: borderWidth)
                .foregroundColor(.purple)
                .frame(width: Constants.avatarSize.width, height: Constants.avatarSize.height)
                Spacer()
            }
            .padding()
            .onChange(of: borderWidthDouble) { oldValue, newValue in
                self.borderWidth = CGFloat(newValue ?? 0)
            }
        }
    }
}

struct StepperField: View {
    let title: String
    @Binding var value: Double?

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 0) {
                Text(title).font(.caption2).foregroundStyle(.secondary)
                HStack {
                    TextField(title, value: $value, format: .number)
                        .textFieldStyle(.roundedBorder)
                        .disableAutocorrection(true)
                    Stepper {
                        Text("")
                    } onIncrement: {
                        value? += 1
                    } onDecrement: {
                        value ?? 0 > 0 ? value? -= 1 : ()
                    }
                }
            }
        }
    }
}

#Preview {
    DemoAvatarView()
}
