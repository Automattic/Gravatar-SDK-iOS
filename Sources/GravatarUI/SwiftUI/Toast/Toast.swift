import SwiftUI

struct Toast: View {
    private enum Constants {
        static let backgroundLight: Color = .init(uiColor: .rgba(30, 30, 30))
        static let backgroundDark: Color = .init(uiColor: .rgba(225, 225, 225))
        static let errorBackgroundLight: Color = .init(uiColor: UIColor.errorBackgroundRed)
        static let errorLineRed: Color = .init(uiColor: UIColor.alertRed)
    }

    @Environment(\.colorScheme) var colorScheme: ColorScheme
    private(set) var toast: ToastItem
    private(set) var dismissHandler: (ToastItem) -> Void

    var body: some View {
        HStack(spacing: 0) {
            Text(toast.message)
                .font(.footnote)
            Spacer(minLength: .DS.Padding.double)
            Button {
                dismissHandler(toast)
            } label: {
                Image(systemName: "xmark")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 12, height: 12)
            }
        }
        .padding(.horizontal, .DS.Padding.double)
        .padding(.vertical, .DS.Padding.split)
        .background(backgroundColor)
        .overlay(
            Rectangle()
                .frame(width: toast.type == .error ? 4 : 0, height: nil, alignment: .leading)
                .foregroundColor(Color.red), alignment: .leading
        )
        .cornerRadius(4)
        .foregroundColor(foregroundColor)
        .shadow(radius: 3, y: 3)
        .zIndex(1)
    }

    var backgroundColor: Color {
        switch toast.type {
        case .info:
            colorScheme == .dark ? Constants.backgroundDark : Constants.backgroundLight
        case .error:
            colorScheme == .dark ? Constants.errorBackgroundLight : Constants.errorBackgroundLight
        }
    }

    var foregroundColor: Color {
        switch toast.type {
        case .info:
            Color(UIColor.systemBackground)
        case .error:
            colorScheme == .dark ? Color(UIColor.gravatarBlack) : Color(UIColor.gravatarBlack)
        }
    }
}

#Preview {
    VStack {
        Toast(toast: .init(
            message: "Avatar updated! It may take a few minutes to appear everywhere.",
            type: .info
        )) { _ in
        }

        Toast(toast: .init(
            message: "Something went wrong.",
            type: .error
        )) { _ in
        }
    }
}
