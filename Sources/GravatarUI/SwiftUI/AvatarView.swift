import Gravatar
import SwiftUI

@MainActor
public struct AvatarView<LoadingView: View, Placeholder: View>: View {
    @ViewBuilder private let loadingView: (() -> LoadingView)?
    @Binding private var forceRefresh: Bool
    @State private var isLoading: Bool = false
    private var url: URL?
    private let placeholderView: (() -> Placeholder)?
    private let cache: ImageCaching
    private let urlSession: URLSession
    private let transaction: Transaction

    @available(*, deprecated, message: "Use the initializer with `placeholderView: (() -> Placeholder)?` instead.")
    public init(
        url: URL?,
        placeholder: Image?,
        cache: ImageCaching = ImageCache.shared,
        urlSession: URLSession = .shared,
        forceRefresh: Binding<Bool> = .constant(false),
        loadingView: (() -> LoadingView)?,
        transaction: Transaction = Transaction()
    ) where Placeholder == AnyView {
        self.url = url
        if let placeholder {
            self.placeholderView = {
                AnyView(placeholder.resizable())
            }
        } else {
            self.placeholderView = nil
        }
        self.cache = cache
        self.loadingView = loadingView
        self.urlSession = urlSession
        self._forceRefresh = forceRefresh
        self.transaction = transaction
    }

    public init(
        url: URL?,
        placeholderView: (() -> Placeholder)? = nil,
        cache: ImageCaching = ImageCache.shared,
        urlSession: URLSession = .shared,
        forceRefresh: Binding<Bool> = .constant(false),
        loadingView: (() -> LoadingView)?,
        transaction: Transaction = Transaction()
    ) {
        self.url = url
        self.placeholderView = placeholderView
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
            placeholderView?()
        @unknown default:
            placeholderView?()
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
        transaction: Transaction(animation: .easeInOut(duration: 1))
    )
    .shape(RoundedRectangle(cornerRadius: 20), borderColor: Color.accentColor, borderWidth: 2)
    .frame(width: 100, height: 100, alignment: .center)
}
