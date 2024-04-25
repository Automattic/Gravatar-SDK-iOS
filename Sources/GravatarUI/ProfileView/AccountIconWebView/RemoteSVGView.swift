import Gravatar
import UIKit
import WebKit

class RemoteSVGView: UIView, WKNavigationDelegate, UIGestureRecognizerDelegate {
    class SVGCache {
        private let cache: NSCache<NSString, NSString> = .init()

        static let shared: SVGCache = .init()

        init() {}

        func setSVG(_ svg: String, forKey key: String) {
            cache.setObject(svg as NSString, forKey: key as NSString)
        }

        func getSVG(forKey key: String) -> String? {
            cache.object(forKey: key as NSString) as String?
        }
    }

    private enum HTMLConstructionError: Error {
        case canNotConvertDataToString
        case notValidSVG
    }

    private let iconSize: CGSize
    private var task: Task<Void, Never>?
    private var iconURL: URL?
    private var tapHandler: (() -> Void)?

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
        return webView
    }()

    private lazy var fallbackImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = AccountButtonBuilder.fallbackIcon
        imageView.isHidden = true
        addSubview(webView)
        addSubview(imageView)
        NSLayoutConstraint.activate([
            webView.widthAnchor.constraint(equalTo: widthAnchor),
            webView.heightAnchor.constraint(equalTo: heightAnchor),
            webView.centerXAnchor.constraint(equalTo: centerXAnchor),
            webView.centerYAnchor.constraint(equalTo: centerYAnchor),
            imageView.widthAnchor.constraint(equalTo: widthAnchor),
            imageView.heightAnchor.constraint(equalTo: heightAnchor),
            imageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: centerYAnchor),
        ])
        return imageView
    }()

    init(frame: CGRect = .zero, iconSize: CGSize, tapHandler: (() -> Void)?) {
        self.iconSize = iconSize
        self.tapHandler = tapHandler
        super.init(frame: frame)
        refresh(paletteType: .system, shouldReloadURL: false)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTap))
        tapGesture.delegate = self
        addGestureRecognizer(tapGesture)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func prepareHTMLString(from url: URL, paletteType: PaletteType) async throws -> String {
        if let svgString = SVGCache.shared.getSVG(forKey: url.absoluteString) {
            return html(withSVG: svgString as String, paletteType: paletteType)
        }
        let data = try Data(contentsOf: url)
        guard let svgString = String(data: data, encoding: .utf8) else {
            throw HTMLConstructionError.canNotConvertDataToString
        }
        guard svgString.trimmingCharacters(in: .whitespacesAndNewlines).lowercased().hasPrefix("<svg") else {
            throw HTMLConstructionError.notValidSVG
        }
        SVGCache.shared.setSVG(svgString, forKey: url.absoluteString)
        return html(withSVG: svgString, paletteType: paletteType)
    }

    private var paletteType: PaletteType = .system

    func refresh(paletteType newPaletteType: PaletteType, shouldReloadURL: Bool = true) {
        self.paletteType = newPaletteType
        fallbackImageView.tintColor = paletteType.palette.foreground.primary
        if let iconURL, shouldReloadURL {
            loadIcon(from: iconURL)
        }
    }

    func loadIcon(from url: URL) {
        if url != iconURL && iconURL != nil {
            // hiding by changing alpha to keep its size
            webView.alpha = 0
        }
        fallbackImageView.isHidden = true
        iconURL = nil
        task?.cancel()
        task = Task {
            do {
                let html = try await prepareHTMLString(from: url, paletteType: paletteType)
                webView.loadHTMLString(html, baseURL: nil)
                iconURL = url
            } catch {
                fallbackImageView.isHidden = false
                webView.alpha = 0
            }
        }
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        webView.alpha = 1
    }

    @objc
    func didTap() {
        tapHandler?()
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        true
    }

    func html(withSVG svg: String, paletteType: PaletteType) -> String {
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
                </style>
            <head/>
            <body>
                <div class=icon>
                \(svg)
                </div>
            </body>
        </html>
        """
    }
}
