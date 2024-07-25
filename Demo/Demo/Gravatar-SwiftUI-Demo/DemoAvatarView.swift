//
//  DemoAvatarView.swift
//  Gravatar-SwiftUI-Demo
//
//  Created by Pinar Olguc on 8.07.2024.
//

import SwiftUI
import GravatarUI

struct DemoAvatarView: View {
    enum Constants {
        static let avatarWidth: CGFloat = 120
        static let borderWidth: CGFloat = 2
    }
    
    @AppStorage("email") private var email: String = ""
    @State var borderWidthDouble: Double? = Constants.borderWidth
    @State var borderWidth: CGFloat = Constants.borderWidth
    @State var forceRefresh: Bool = false
    @State var isAnimated: Bool = true
    
    var avatarURL: AvatarURL? {
        AvatarURL(
            with: .email(email),
            options: .init(
                preferredSize: .points(Constants.avatarWidth),
                defaultAvatarOption: .status404
            )
        )
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            TextField("Email", text: $email)
                .textInputAutocapitalization(.never)
                .keyboardType(.emailAddress)
                .disableAutocorrection(true)
            TextField("Border width", value: $borderWidthDouble, format: .number)
                .disableAutocorrection(true)
            Toggle("Force refresh", isOn: $forceRefresh)
            Toggle("Animated", isOn: $isAnimated)
            
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
            .shape(RoundedRectangle(cornerRadius: 8),
                   borderColor: .purple,
                   borderWidth: borderWidth)
            .foregroundColor(.purple)
            .frame(width: Constants.avatarWidth)
        }
        .padding()
        .onChange(of: borderWidthDouble) { oldValue, newValue in
            self.borderWidth = CGFloat(newValue ?? 0)
        }
    }
}

#Preview {
    DemoAvatarView()
}
