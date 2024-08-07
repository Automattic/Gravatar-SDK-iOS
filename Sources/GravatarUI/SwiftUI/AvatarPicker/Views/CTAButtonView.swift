import SwiftUI

struct CTAButtonView: View {
    let titleKey: LocalizedStringKey

    public init(_ key: LocalizedStringKey) {
        self.titleKey = key
    }

    public var body: some View {
        Text(titleKey)
            .font(.callout).fontWeight(.bold)
            .frame(maxWidth: .infinity)
            .foregroundColor(.white)
            .padding(.vertical, .DS.Padding.split)
            .padding(.horizontal, .DS.Padding.double)
            .background(RoundedRectangle(cornerRadius: 4).fill(Color(uiColor: .gravatarBlue)))
    }
}

extension CTAButtonView {
    static func withButton(title: String, action: @escaping () -> Void) -> Button<CTAButtonView> {
        Button {
            action()
        } label: {
            CTAButtonView(title.localized)
        }
    }
}

#Preview {
    CTAButtonView("I am a button")
        .padding()
}

#Preview("Dark mode") {
    CTAButtonView("I am a button")
        .padding()
        .preferredColorScheme(.dark)
}
