import SwiftUI
import Gravatar

struct AvatarView<LoadingView: View, ClipShape: Shape, Content: View>: View {
    
    // Default content type
    struct DefaultContent: View {
        let image: Image
        @Binding var clipShape: ClipShape
        @Binding var borderColor: Color?
        @Binding var borderWidth: CGFloat?
        
        var body: some View {
            image
                .resizable()
                .scaledToFit()
                .clipShape(clipShape)
                .overlay(
                    clipShape
                        .stroke(borderColor ?? Color.clear, lineWidth: borderWidth ?? 0)
                )
        }
    }
    
    typealias LoadingViewBlock = () -> LoadingView
    typealias ImageContentBlock = (_ image: Image, _ isPlaceholder: Bool) -> Content
    @Binding private var forceRefresh: Bool
    @ViewBuilder let loadingView: LoadingViewBlock?
    
    let avatarURL: AvatarURL?
    let placeholder: Image?
    let cache: ImageCaching
    let urlSession: URLSession
    private let imageContent: ImageContentBlock
    
    /// Use this initilizer to fully customize the content `Image`.
    public init(avatarURL: AvatarURL?,
                placeholder: Image?,
                cache: ImageCaching = ImageCache.shared,
                urlSession: URLSession = .shared,
                forceRefresh: Binding<Bool> = .constant(false),
                loadingView: LoadingViewBlock?,
                imageContent: @escaping ImageContentBlock) where ClipShape == Circle {
        self.avatarURL = avatarURL
        self.placeholder = placeholder
        self.cache = cache
        self.loadingView = loadingView
        self.urlSession = urlSession
        self.imageContent = imageContent
        self._forceRefresh = forceRefresh
    }
    
    /// Use this initilizer to create the content `Image` with a given clipShape, borderColor and borderWidth.
    public init(avatarURL: AvatarURL?,
                placeholder: Image?,
                cache: ImageCaching = ImageCache.shared,
                urlSession: URLSession = .shared,
                forceRefresh: Binding<Bool> = .constant(false),
                loadingView: LoadingViewBlock?,
                clipShape: Binding<ClipShape> = .constant(Circle()),
                borderColor: Binding<Color?> = .constant(nil),
                borderWidth: Binding<CGFloat?> = .constant(nil)) where Content == AnyView {
        self.avatarURL = avatarURL
        self.placeholder = placeholder
        self.cache = cache
        self.loadingView = loadingView
        self.urlSession = urlSession
        self._forceRefresh = forceRefresh
        self.imageContent = { image, isPlaceholder in
            AnyView(DefaultContent(image: image,
                                   clipShape: clipShape,
                                   borderColor: borderColor,
                                   borderWidth: borderWidth))
        }
    }
    
    var body: some View {
        CachedAsyncImage(url: avatarURL?.url,
                         cache: cache,
                         urlSession: urlSession,
                         forceRefresh: $forceRefresh) { phase, isLoading in
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

#Preview {
    let avatarURL = AvatarURL(url: URL(string: "https://gravatar.com/avatar/680ba0b75f610ad8d939dbbd416dcced2d858656bd593ae81380ae8d2423b8cd")!, options: .init())!
    return AvatarView(
        avatarURL: avatarURL,
        placeholder: Image(systemName: "person"),
        loadingView: {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle())
        },
        clipShape: .constant(RoundedRectangle(cornerRadius: 20)),
        borderColor: .constant(.accentColor),
        borderWidth: .constant(2)
    )
    .frame(width: 100, height: 100, alignment: .center)
}
