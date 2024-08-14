import SwiftUI

struct Toast: View {
    private enum Constants {
        static let backgroundLight: Color = .init(uiColor: .rgba(30, 30, 30))
        static let backgroundDark: Color = .init(uiColor: .rgba(225, 225, 225))
    }

    @Environment(\.colorScheme) var colorScheme: ColorScheme
    private(set) var toast: ToastItem
    private(set) var dismissHandler: (ToastItem) -> Void

    var body: some View {
        HStack(spacing: 0) {
            Text(toast.message.localized)
                .font(.footnote)
            Spacer(minLength: .DS.Padding.medium)
            Button {
                dismissHandler(toast)
            } label: {
                Text("Got it")
                    .font(.footnote)
                    .underline(true)
            }
        }
        .padding(.horizontal, .DS.Padding.double)
        .padding(.vertical, .DS.Padding.split)
        .background(backgroundColor)
        .cornerRadius(4)
        .foregroundColor(Color(UIColor.systemBackground))
        .shadow(radius: 3, y: 3)
        .zIndex(1)
    }

    var backgroundColor: Color {
        colorScheme == .dark ? Constants.backgroundDark : Constants.backgroundLight
    }
}

#Preview {
    Toast(toast: .init(
        message: "Avatar updated! It may take a few minutes to appear everywhere.",
        type: .info
    )) { _ in
    }
}
