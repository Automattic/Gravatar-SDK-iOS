import Gravatar
import SwiftUI

@MainActor
public struct AvatarView<LoadingView: View>: View {
    @ViewBuilder private let loadingView: (() -> LoadingView)?
    @Binding private var forceRefresh: Bool
    @State private var isLoading: Bool = false
    private var url: URL?
    private let placeholder: Image?
    private let cache: ImageCaching
    private let urlSession: URLSession
    private let transaction: Transaction

    public init(
        url: URL?,
        placeholder: Image?,
        cache: ImageCaching = ImageCache.shared,
        urlSession: URLSession = .shared,
        forceRefresh: Binding<Bool> = .constant(false),
        loadingView: (() -> LoadingView)?,
        transaction: Transaction = Transaction(),
        newThing: String
    ) {
        self.url = url
        self.placeholder = placeholder
        self.cache = cache
        self.loadingView = loadingView
        self.urlSession = urlSession
        self._forceRefresh = forceRefresh
        self.transaction = transaction
    }

    public var body: some View {
        CachedAsyncImage(
            url: url,
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
            image.resizable()
        case .failure, .empty:
            placeholder?.resizable()
        @unknown default:
            placeholder?.resizable()
        }
    }
}

#Preview {
    let avatarURL = AvatarURL(
        with: .email("email@google.com"),
        options: .init(preferredSize: .points(100))
    )
    return AvatarView(
        url: avatarURL?.url,
        placeholder: Image(systemName: "person")
            .renderingMode(.template)
            .resizable(),
        loadingView: {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle())
        },
        transaction: Transaction(animation: .easeInOut(duration: 1)), newThing: ""
    )
    .shape(RoundedRectangle(cornerRadius: 20), borderColor: Color.accentColor, borderWidth: 2)
    .frame(width: 100, height: 100, alignment: .center)
}
