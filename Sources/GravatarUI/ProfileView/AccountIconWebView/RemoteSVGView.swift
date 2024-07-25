import Gravatar
import UIKit
import WebKit

public class RemoteSVGButton: UIControl, WKNavigationDelegate {
    private enum HTMLConstructionError: Error {
        case canNotConvertDataToString
        case notValidSVG
    }

    public override var isHighlighted: Bool {
        didSet {
            webView.alpha = isHighlighted ? 0.8 : 1
            fallbackImageView.alpha = isHighlighted ? 0.8 : 1
        }
    }

    private let iconSize: CGSize
    private var task: Task<Void, Never>?
    private var iconURL: URL?
    private static let cache: NSCache<NSString, NSString> = .init()

    public init(iconSize: CGSize) {
        self.iconSize = iconSize
        super.init()
    }

    private lazy var webView: WKWebView = {
        let webView = WKWebView()
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.scrollView.showsHorizontalScrollIndicator = false
        webView.scrollView.showsVerticalScrollIndicator = false
        webView.scrollView.scrollIndicatorInsets = .zero
        webView.scrollView.isScrollEnabled = false
        webView.scrollView.contentInset = .zero
        webView.scrollView.contentInsetAdjustmentBehavior = .never
        webView.navigationDelegate = self
        webView.isOpaque = false
        webView.backgroundColor = .clear
        webView.scrollView.backgroundColor = .clear
        webView.isUserInteractionEnabled = false
        return webView
    }()

    private lazy var fallbackImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = AccountButtonBuilder.fallbackIcon
        imageView.isHidden = true
        imageView.isUserInteractionEnabled = false
        return imageView
    }()

    init(frame: CGRect = .zero, iconSize: CGSize) {
        self.iconSize = iconSize
        super.init(frame: frame)
        addSubview(webView)
        addSubview(fallbackImageView)
        NSLayoutConstraint.activate([
            webView.widthAnchor.constraint(equalTo: widthAnchor),
            webView.heightAnchor.constraint(equalTo: heightAnchor),
            webView.centerXAnchor.constraint(equalTo: centerXAnchor),
            webView.centerYAnchor.constraint(equalTo: centerYAnchor),
            fallbackImageView.widthAnchor.constraint(equalTo: widthAnchor),
            fallbackImageView.heightAnchor.constraint(equalTo: heightAnchor),
            fallbackImageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            fallbackImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
        ])
        refresh(paletteType: .system, shouldReloadURL: false)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func prepareHTMLString(from url: URL) async throws -> String {
        if let svgString = Self.cache.object(forKey: url.absoluteString as NSString) as String? {
            return html(withSVG: svgString as String)
        }

        let (data, _) = try await URLSession.shared.data(from: url)
        guard let svgString = String(data: data, encoding: .utf8) else {
            throw HTMLConstructionError.canNotConvertDataToString
        }
        guard svgString.trimmingCharacters(in: .whitespacesAndNewlines).lowercased().hasPrefix("<svg") else {
            throw HTMLConstructionError.notValidSVG
        }
        Self.cache.setObject(svgString as NSString, forKey: url.absoluteString as NSString)
        return html(withSVG: svgString)
    }

    private var paletteType: PaletteType = .system

    public func refresh(paletteType newPaletteType: PaletteType, shouldReloadURL: Bool = true) {
        self.paletteType = newPaletteType
        fallbackImageView.tintColor = paletteType.palette.foreground.primary
        if let iconURL, shouldReloadURL {
            loadIcon(from: iconURL)
        }
    }

    public func loadIcon(from url: URL) {
        if url != iconURL && iconURL != nil {
            webView.isHidden = true
        }
        fallbackImageView.isHidden = true
        iconURL = nil
        task?.cancel()
        task = Task {
            do {
                let html = try await prepareHTMLString(from: url)
                webView.loadHTMLString(html, baseURL: nil)
                iconURL = url
            } catch {
                fallbackImageView.isHidden = false
                webView.isHidden = true
            }
        }
    }

    public nonisolated func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        Task {
            await showWebView()
        }
    }

    func showWebView() {
        webView.isHidden = false
    }

    func html(withSVG svg: String) -> String {
        """
        <html>
            <head>
                <meta name="viewport" content="width=\(iconSize.width)">
                <style>
                .icon svg {
                    height: 100%;
                    width: 100%;
                }
                .icon path {
                    fill: \(paletteType.palette.foreground.primary.hexString());
                }
                body {
                    margin: 0;
                    background-color: transparent;
                }
                @keyframes fadeIn {
                    0% { opacity: 0; }
                    100% { opacity: 1; }
                }
                .fade-in { animation: fadeIn 0.2s; }
                </style>
            <head/>
            <body>
                <div class="icon fade-in">
                \(svg)
                </div>
            </body>
        </html>
        """
    }
}
