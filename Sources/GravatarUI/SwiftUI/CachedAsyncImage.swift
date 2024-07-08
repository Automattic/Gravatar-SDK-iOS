import SwiftUI
import Foundation
import Gravatar

@MainActor
struct CachedAsyncImage<Content>: View, Sendable where Content: View {
    
    @State private var phase: AsyncImagePhase
    @Binding private var forceRefresh: Bool
    @State private var isLoading: Bool
    
    private let url: URL?
    private let urlSession: URLSession
    private let scale: CGFloat
    private let transaction: Transaction
    private let content: (AsyncImagePhase, Bool) -> Content
    private let cache: ImageCaching
    private let imageDownloader: ImageDownloader
    
    public var body: some View {
        content(phase, isLoading)
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
    
    public init(url: URL?,
                cache: ImageCaching = ImageCache.shared,
                urlSession: URLSession = .shared,
                forceRefresh: Binding<Bool> = .constant(false),
                scale: CGFloat = UITraitCollection.current.displayScale,
                transaction: Transaction = Transaction(),
                @ViewBuilder content: @escaping (AsyncImagePhase, Bool) -> Content) {
        self.url = url
        self.urlSession = urlSession
        self.scale = scale
        self.transaction = transaction
        self.content = content
        self._forceRefresh = forceRefresh
        self._isLoading = State(wrappedValue: false)
        self._phase = State(wrappedValue: .empty)
        self.cache = cache
        self.imageDownloader = ImageDownloadService(urlSession: urlSession, cache: cache)
        print("CachedAsyncImage init")
    }
    
    @Sendable
    private func load() async {
        print("start - \(String(describing: phase))")
        defer { print("end - \(String(describing: phase))") }
        guard let url else {
            withAnimation(transaction.animation) {
                phase = .empty
            }
            return
        }
        
        if !forceRefresh, let cacheEntry = await cache.getEntry(with: url.absoluteString) {
            switch cacheEntry {
            case .ready(let uiImage):
                phase = .success(Image(uiImage: uiImage))
                return
            case .inProgress:
                break
            }
        }
        do {
            isLoading = true
            let result = try await imageDownloader.fetchImage(with: url, forceRefresh: forceRefresh, processingMethod: .common(scaleFactor: scale))
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
    CachedAsyncImage(url: URL(string: "https://gravatar.com/avatar/680ba0b75f610ad8d939dbbd416dcced2d858656bd593ae81380ae8d2423b8cd?s=300")) { phase, isLoading in
        switch phase {
        case .empty:
            Text("empty")
        case .success(let image):
            image
        case .failure(let error):
            Text("failure")
        default:
            Text("failure")
        }
    }
}
