import UIKit
import WebKit
import Gravatar

class AccountIconWebView: WKWebView, WKNavigationDelegate {
    
    class SVGCache {
        private let cache: NSCache<NSString, NSString> = NSCache<NSString, NSString>()

        public static let shared: SVGCache = SVGCache()

        public init() {}

        public func setSVG(_ svg: String, forKey key: String) {
            cache.setObject(svg as NSString, forKey: key as NSString)
        }

        public func getSVG(forKey key: String) -> String? {
            cache.object(forKey: key as NSString) as String?
        }
    }

    private enum HTMLConstructionError: Error {
        case canNotConvertDataToString
    }
    
    private let iconSize: CGSize
    var paletteType: PaletteType {
        didSet {
            guard let iconURL else { return }
            load(from: iconURL)
        }
    }
    
    private var task: Task<Void, Never>?
    private var iconURL: URL?
    
    private lazy var fallbackImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = AccountButtonBuilder.fallbackIcon
        imageView.isHidden = true
        addSubview(imageView)
        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalTo: widthAnchor),
            imageView.heightAnchor.constraint(equalTo: heightAnchor),
            imageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: centerYAnchor),
        ])
        return imageView
    }()
    
    init(frame: CGRect = .zero, iconSize: CGSize, paletteType: PaletteType) {
        self.iconSize = iconSize
        self.paletteType = paletteType
        super.init(frame: frame, configuration: WKWebViewConfiguration())
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.scrollIndicatorInsets = .zero
        scrollView.isScrollEnabled = false
        scrollView.contentInset = .zero
        scrollView.contentInsetAdjustmentBehavior = .never
        navigationDelegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func prepareHTMLString(from url: URL) async throws -> String {
        if let svgString = SVGCache.shared.getSVG(forKey: url.absoluteString) {
            return html(withSVG: svgString as String)
        }
        let data = try Data(contentsOf: url)
        guard let svgString = String(data: data, encoding: .utf8) else {
            throw HTMLConstructionError.canNotConvertDataToString
        }
        SVGCache.shared.setSVG(svgString, forKey: url.absoluteString)
        return html(withSVG: svgString)
    }
    
    private func html(withSVG svg: String) -> String {
        htmlString(
            svgString: svg,
            fillColor: paletteType.palette.foreground.primary.hexString(),
            backgroundColor: paletteType.palette.background.primary.hexString()
        )
    }
    
    func load(from url: URL) {
        self.iconURL = url
        task?.cancel()
        task = Task {
            do {
                fallbackImageView.isHidden = true
                let html = try await prepareHTMLString(from: url)
                loadHTMLString(html, baseURL: nil)
            } catch {
                loadHTMLString("", baseURL: nil)
                fallbackImageView.isHidden = false
            }
        }
    }
}


func htmlString(svgString: String, fillColor: String, backgroundColor: String) -> String {
"""
<html>
    <head>
    <meta name="viewport" content="width=96px, height=96px, shrink-to-fit=YES">
    <style>
    .icon svg {
        height: 100%;
        width: 100%;
        margin: 0px 0px 0px 0px;
        padding: 0px;
        display:flex;
        align-items:center;
        justify-content:center;
    }
    .icon path {
        fill: \(fillColor);
    }
    body {
        margin: 0;
        background-color: \(backgroundColor);
    }
    </style>
    <head/>
<body>

<div class=icon>
\(svgString)
</div>

</body>
</html>
"""
}
