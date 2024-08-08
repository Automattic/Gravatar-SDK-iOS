import Gravatar
import SwiftUI

@MainActor
struct AvatarPickerProfileView: View {
    private enum Constants {
        static let avatarLength: CGFloat = 72
    }

    struct Model {
        var displayName: String
        var location: String
        var profileURL: URL?
    }

    @Binding var avatarURL: URL?
    @Binding var model: Model?
    @Binding var isLoading: Bool
    @StateObject private var placeholderColorManager: ProfileViewPlaceholderColorManager = .init()

    private(set) var viewProfileAction: ((URL?) -> Void)? = nil

    var body: some View {
        HStack(alignment: .center, spacing: .DS.Padding.single) {
            avatarView()
            if let model {
                VStack(alignment: .leading, spacing: 0) {
                    Text(model.displayName)
                        .font(.title3)
                        .fontWeight(.bold)
                    Text(model.location)
                        .font(.footnote)
                        .foregroundColor(Color(UIColor.secondaryLabel))
                    Button("Discover Your Gravatar Card →") {
                        viewProfileAction?(model.profileURL)
                    }
                    .font(.footnote)
                    .foregroundColor(Color(UIColor.label))
                }
            } else {
                emptyViews()
            }
        }
        .onChange(of: isLoading) { newValue in
            placeholderColorManager.toggleAnimation(newValue)
        }
        .onAppear {
            placeholderColorManager.toggleAnimation(isLoading)
        }
    }

    func emptyViews() -> some View {
        VStack(alignment: .leading, spacing: .DS.Padding.half, content: {
            RoundedRectangle(cornerRadius: 12)
                .frame(width: 180, height: 24)
            RoundedRectangle(cornerRadius: 6)
                .frame(width: 100, height: 12)
            RoundedRectangle(cornerRadius: 6)
                .frame(width: 140, height: 12)
        })
        .foregroundColor(placeholderColorManager.placeholderColor)
    }

    func avatarView() -> some View {
        AvatarView(
            url: avatarURL,
            placeholder: nil,
            loadingView: {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
            }
        )
        .scaledToFill()
        .frame(width: Constants.avatarLength, height: Constants.avatarLength)
        .background(placeholderColorManager.placeholderColor)
        .aspectRatio(1, contentMode: .fill)
        .shape(Circle())
    }
}

#Preview {
    AvatarPickerProfileView(
        avatarURL: .constant(nil),
        model: .constant(
            .init(
                displayName: "Shelly Kimbrough",
                location: "San Antonio, TX",
                profileURL: URL(string: "https://gravatar.com")
            )
        ),
        isLoading: .constant(false)
    )
}

#Preview("Empty") {
    AvatarPickerProfileView(avatarURL: .constant(nil), model: .constant(nil), isLoading: .constant(false))
}

#Preview("Empty & Loading") {
    AvatarPickerProfileView(avatarURL: .constant(nil), model: .constant(nil), isLoading: .constant(true))
}
