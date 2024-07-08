import Gravatar
import SwiftUI

@MainActor
struct AvatarView<LoadingView: View, Content: View>: View {
    typealias LoadingViewBlock = () -> LoadingView
    typealias ImageContentBlock = (_ image: Image, _ isPlaceholder: Bool) -> Content
    @ViewBuilder private let loadingView: LoadingViewBlock?
    @Binding private var forceRefresh: Bool
    @State private var isLoading: Bool = false
    private var avatarURL: AvatarURL?
    private let placeholder: Image?
    private let cache: ImageCaching
    private let urlSession: URLSession
    private let transaction: Transaction
    private let imageContent: ImageContentBlock

    /// Use this initializer to fully customize the content `Image`.
    init(
        avatarURL: AvatarURL?,
        placeholder: Image?,
        cache: ImageCaching = ImageCache.shared,
        urlSession: URLSession = .shared,
        forceRefresh: Binding<Bool> = .constant(false),
        loadingView: LoadingViewBlock?,
        transaction: Transaction = Transaction(),
        imageContent: @escaping ImageContentBlock
    ) {
        self.avatarURL = avatarURL
        self.placeholder = placeholder
        self.cache = cache
        self.loadingView = loadingView
        self.urlSession = urlSession
        self._forceRefresh = forceRefresh
        self.imageContent = imageContent
        self.transaction = transaction
    }

    /// Use this initializer to create the content `Image` with a given clipShape, borderColor and borderWidth.
    init<ClipShape>(
        avatarURL: AvatarURL?,
        placeholder: Image?,
        cache: ImageCaching = ImageCache.shared,
        urlSession: URLSession = .shared,
        forceRefresh: Binding<Bool> = .constant(false),
        loadingView: LoadingViewBlock?,
        transaction: Transaction = Transaction(),
        clipShape: ClipShape,
        borderColor: Color = .clear,
        borderWidth: CGFloat = 0
    ) where Content == DefaultAvatarContent<ClipShape> {
        self.init(
            avatarURL: avatarURL,
            placeholder: placeholder,
            cache: cache,
            urlSession: urlSession,
            forceRefresh: forceRefresh,
            loadingView: loadingView,
            transaction: transaction
        ) { image, _ in
            DefaultAvatarContent(
                image: image,
                clipShape: clipShape,
                borderColor: borderColor,
                borderWidth: borderWidth
            )
        }
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
            imageContent(image, false)
        case .failure, .empty:
            if let placeholder {
                imageContent(placeholder, true)
            }
        @unknown default:
            if let placeholder {
                imageContent(placeholder, true)
            }
        }
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
    guard let avatarURL = AvatarURL(
        with: .email("email@google.com"),
        options: .init(preferredSize: .points(100))
    ) else {
        return Text("Invalid URL")
    }
    return AvatarView(
        avatarURL: avatarURL,
        placeholder: Image(systemName: "person")
            .renderingMode(.template)
            .resizable(),
        loadingView: {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle())
        },
        transaction: Transaction(animation: .easeInOut(duration: 1)),
        clipShape: RoundedRectangle(cornerRadius: 20),
        borderColor: .accentColor,
        borderWidth: 2
    )
    .frame(width: 100, height: 100, alignment: .center)
}
