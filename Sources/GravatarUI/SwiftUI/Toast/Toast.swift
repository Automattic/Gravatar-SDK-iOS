import Gravatar
import SwiftUI

struct Toast: View {
    private enum Constants {
        static let backgroundLight: Color = .init(uiColor: .rgba(30, 30, 30))
        static let backgroundDark: Color = .init(uiColor: .rgba(225, 225, 225))
        static let errorBackgroundLight: Color = .init(uiColor: UIColor.errorBackgroundRed)
        static let errorLineRed: Color = .init(uiColor: UIColor.alertRed)
        static let warningBackgroundLight: Color = .init(uiColor: .yellowishWhite)
        static let warningLineLight: Color = .init(uiColor: .butterscotchYellow)
        static let warningTextLight: Color = .init(uiColor: .gravatarBlack)
        static let warningBackgroundDark: Color = .init(uiColor: .chocolateBrown)
        static let warningLineDark: Color = .init(uiColor: .harvestYellow)
        static let warningTextDark: Color = .init(uiColor: .harvestYellow)
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
                .frame(width: toast.type != .info ? 4 : 0, height: nil, alignment: .leading)
                .foregroundColor(lineColor), alignment: .leading
        )
        .cornerRadius(4)
        .foregroundColor(foregroundColor)
        .if(toast.shouldShowShadow, transform: { view in
            view.shadow(radius: 3, y: 3)
        })
        .zIndex(1)
    }

    var backgroundColor: Color {
        switch toast.type {
        case .info:
            colorScheme == .dark ? Constants.backgroundDark : Constants.backgroundLight
        case .warning:
            colorScheme == .dark ? Constants.warningBackgroundDark : Constants.warningBackgroundLight
        case .error:
            colorScheme == .dark ? Constants.errorBackgroundLight : Constants.errorBackgroundLight
        }
    }

    var foregroundColor: Color {
        switch toast.type {
        case .info:
            Color(UIColor.systemBackground)
        case .warning:
            colorScheme == .dark ? Constants.warningTextDark : Constants.warningTextLight
        case .error:
            colorScheme == .dark ? Color(UIColor.gravatarBlack) : Color(UIColor.gravatarBlack)
        }
    }

    var lineColor: Color {
        switch toast.type {
        case .info:
            .clear
        case .warning:
            colorScheme == .dark ? Constants.warningLineDark : Constants.warningLineLight
        case .error:
            Constants.errorLineRed
        }
    }
}

#Preview {
    VStack {
        Toast(toast: .init(
            message: "Avatar updated! It may take a few minutes to appear everywhere.",
            type: .info,
            stackingBehavior: .avoidStackingWithSameMessage
        )) { _ in
        }

        Toast(toast: .init(
            message: "No image selected. Please select one or the default will be used.",
            type: .warning,
            stackingBehavior: .avoidStackingWithSameMessage
        )) { _ in
        }

        Toast(toast: .init(
            message: "Something went wrong.",
            type: .error,
            stackingBehavior: .alwaysStack
        )) { _ in
        }
    }
    .padding()
}
