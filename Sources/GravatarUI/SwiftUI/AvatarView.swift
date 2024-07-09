import Gravatar
import SwiftUI

@MainActor
struct AvatarView<LoadingView: View>: View {
    typealias LoadingViewBlock = () -> LoadingView
    @ViewBuilder private let loadingView: LoadingViewBlock?
    @Binding private var forceRefresh: Bool
    @State private var isLoading: Bool = false
    private var avatarURL: AvatarURL?
    private let placeholder: Image?
    private let cache: ImageCaching
    private let urlSession: URLSession
    private let transaction: Transaction

    init(
        avatarURL: AvatarURL?,
        placeholder: Image?,
        cache: ImageCaching = ImageCache.shared,
        urlSession: URLSession = .shared,
        forceRefresh: Binding<Bool> = .constant(false),
        loadingView: LoadingViewBlock?,
        transaction: Transaction = Transaction()
    ) {
        self.avatarURL = avatarURL
        self.placeholder = placeholder
        self.cache = cache
        self.loadingView = loadingView
        self.urlSession = urlSession
        self._forceRefresh = forceRefresh
        self.transaction = transaction
    }

    var body: some View {
        CachedAsyncImage(
            url: avatarURL?.url,
            cache: cache,
            urlSession: urlSession,
            forceRefresh: $forceRefresh,
            transaction: transaction,
            isLoading: $isLoading
        ) { phase in
            ZStack {
                content(for: phase)

                if isLoading {
                    if let loadingView = loadingView?() {
                        loadingView
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func content(for phase: AsyncImagePhase) -> some View {
        switch phase {
        case .success(let image):
            scaledImage(image)
        case .failure, .empty:
            if let placeholder {
                scaledImage(placeholder)
            }
        @unknown default:
            if let placeholder {
                scaledImage(placeholder)
            }
        }
    }

    private func scaledImage(_ image: Image) -> some View {
        image
            .resizable()
            .scaledToFit()
    }

    func avatarShape<ClipShape: Shape>(_ shape: ClipShape, borderColor: Color = .clear, borderWidth: CGFloat = 0) -> some View {
        self
            .clipShape(shape)
            .overlay(
                shape
                    .stroke(borderColor, lineWidth: borderWidth)
            )
    }
}

// Default content type
struct DefaultAvatarContent<ClipShape: Shape>: View {
    let image: Image
    var clipShape: ClipShape
    var borderColor: Color
    var borderWidth: CGFloat

    var body: some View {
        image
            .resizable()
            .scaledToFit()
            .clipShape(clipShape)
            .overlay(
                clipShape
                    .stroke(borderColor, lineWidth: borderWidth)
            )
    }
}

#Preview {
    let avatarURL = AvatarURL(
        with: .email("email@google.com"),
        options: .init(preferredSize: .points(100))
    )
    return AvatarView(
        avatarURL: avatarURL,
        placeholder: Image(systemName: "person")
            .renderingMode(.template)
            .resizable(),
        loadingView: {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle())
        },
        transaction: Transaction(animation: .easeInOut(duration: 1))
    )
    .avatarShape(RoundedRectangle(cornerRadius: 20), borderColor: Color.accentColor, borderWidth: 2)
    .frame(width: 100, height: 100, alignment: .center)
}
