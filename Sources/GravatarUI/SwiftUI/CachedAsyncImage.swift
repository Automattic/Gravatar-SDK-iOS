import Foundation
import Gravatar
import SwiftUI

@MainActor
struct CachedAsyncImage<Content: View>: View {
    @State private var phase: AsyncImagePhase
    @Binding private var forceRefresh: Bool
    @Binding private var isLoading: Bool

    private let url: URL?
    private let urlSession: URLSession
    private let scale: CGFloat
    private let transaction: Transaction
    private let content: (AsyncImagePhase) -> Content
    private let cache: ImageCaching
    private let imageDownloader: ImageDownloader

    var body: some View {
        content(phase)
            .onChange(of: forceRefresh) { newValue in
                if newValue {
                    Task {
                        await load()
                    }
                }
            }
            .task(id: url) {
                await load()
            }
    }

    init(
        url: URL?,
        cache: ImageCaching = ImageCache.shared,
        urlSession: URLSession = .shared,
        forceRefresh: Binding<Bool> = .constant(false),
        scale: CGFloat = UITraitCollection.current.displayScale,
        transaction: Transaction = Transaction(),
        isLoading: Binding<Bool> = .constant(false),
        @ViewBuilder content: @escaping (AsyncImagePhase) -> Content
    ) {
        self.url = url
        self.urlSession = urlSession
        self.scale = scale
        self.transaction = transaction
        self.content = content
        self._forceRefresh = forceRefresh
        self._isLoading = isLoading
        self._phase = State(wrappedValue: .empty)
        self.cache = cache
        self.imageDownloader = ImageDownloadService(urlSession: urlSession, cache: cache)
    }

    @Sendable
    private func load() async {
        guard let url else {
            withAnimation(transaction.animation) {
                phase = .empty
            }
            return
        }
        do {
            isLoading = true
            let result = try await imageDownloader.fetchImage(
                with: url,
                forceRefresh: forceRefresh,
                processingMethod: .common(scaleFactor: scale)
            )
            withAnimation(transaction.animation) {
                phase = .success(Image(uiImage: result.image))
            }
            isLoading = false
        } catch {
            withAnimation(transaction.animation) {
                phase = .failure(error)
            }
            isLoading = false
        }
    }
}

#Preview {
    guard let avatarURL = AvatarURL(
        with: .email("email@google.com"),
        options: .init(preferredSize: .points(100))
    ) else {
        return Text("Invalid URL")
    }
    return CachedAsyncImage(
        url: avatarURL.url,
        transaction: Transaction(animation: .easeInOut(duration: 1))
    ) { phase in
        switch phase {
        case .empty:
            Text("empty")
        case .success(let image):
            image
        case .failure:
            Text("failure")
        default:
            Text("failure")
        }
    }
}
