import SwiftUI

struct ContentLoadingErrorView<ActionButton: View>: View {
    let title: String?
    let subtext: String
    let image: Image?
    let actionButton: () -> ActionButton
    let innerPadding: EdgeInsets
    @Environment(\.colorScheme) var colorScheme: ColorScheme

    var body: some View {
        VStack {
            VStack(alignment: .leading, spacing: 0) {
                if let title {
                    Text(title)
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(Color(UIColor.label))
                        .padding(0)
                }
                Text(subtext)
                    .font(.subheadline)
                    .foregroundColor(Color(UIColor.secondaryLabel))
                    .padding(.top, .DS.Padding.half)

                if let image {
                    VStack(alignment: .center, content: {
                        image
                            .resizable()
                            .scaledToFit()
                            .frame(width: 96, height: 96)
                            .padding(.init(top: .DS.Padding.medium, leading: 0, bottom: 0, trailing: 0))
                    })
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 0)
                }
                actionButton()
                    .padding(.init(top: .DS.Padding.medium, leading: 0, bottom: 0, trailing: 0))
            }
            .padding(innerPadding)
            .avatarPickerBorder(colorScheme: colorScheme)
        }
        .fixedSize(horizontal: false, vertical: true)
    }
}

#Preview {
    ContentLoadingErrorView(
        title: "Ooops",
        subtext: "Something went wrong",
        image: nil,
        actionButton: {
            CTAButtonView("Retry")
        },
        innerPadding: .init(top: 12, leading: 12, bottom: 12, trailing: 12)
    )
    .padding()
}

#Preview("With image") {
    ContentLoadingErrorView(
        title: "Ooops",
        subtext: "Something went wrong",
        image: Image("setup-avatar-emoji", bundle: .module),
        actionButton: {
            CTAButtonView("Retry")
        },
        innerPadding: .init(top: 12, leading: 12, bottom: 12, trailing: 12)
    )
    .padding()
}
