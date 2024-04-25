import Gravatar
import UIKit
import WebKit

class AccountIconWebView: WKWebView, WKNavigationDelegate, UIGestureRecognizerDelegate {
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
    private var tapHandler: (() -> Void)?

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

    init(frame: CGRect = .zero, iconSize: CGSize, paletteType: PaletteType, tapHandler: (() -> Void)?) {
        self.iconSize = iconSize
        self.paletteType = paletteType
        self.tapHandler = tapHandler
        super.init(frame: frame, configuration: WKWebViewConfiguration())
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.scrollIndicatorInsets = .zero
        scrollView.isScrollEnabled = false
        scrollView.contentInset = .zero
        scrollView.contentInsetAdjustmentBehavior = .never
        navigationDelegate = self
        isOpaque = false
        backgroundColor = .clear
        scrollView.backgroundColor = .clear
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTap))
        tapGesture.delegate = self
        addGestureRecognizer(tapGesture)
    }

    @available(*, unavailable)
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

    @objc
    func didTap() {
        tapHandler?()
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        true
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
