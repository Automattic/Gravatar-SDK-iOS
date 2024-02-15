import Foundation

public struct GravatarURL {
    private enum Defaults {
        static let scheme = "https"
        static let host = "secure.gravatar.com"
        static let unknownHash = "ad516503a11cd5ca435acc9bb6523536"
        static let baseURL = "https://gravatar.com/avatar/"
        static let imageSize = 80
    }

    public let canonicalURL: URL

    public func url(with options: GravatarImageDownloadOptions) -> URL {
        // TODO: Find a way to remove explicit unwrap.
        // When `GravatarURL` is initialized successfully, the `canonicalURL` is a valid URL.
        // Adding query items from the options sets, which is controlled by the SDK, should be a guaranteed success.
        // Therefore returning an optional is not ideal, since makes little sence in this context.
        // In the other hand, we get this explisit unwrap, because of how `URLComponents` works.
        canonicalURL.addQueryItems(from: options)
    }

    public static func isGravatarURL(_ url: URL) -> Bool {
        guard
            let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
            let host = components.host
        else {
            return false
        }

        return (host.hasSuffix(".gravatar.com") || host == "gravatar.com")
            && components.path.hasPrefix("/avatar/")
    }

    /// Returns the Gravatar URL, for a given email, with the specified size + rating.
    ///
    /// - Parameters:
    ///     - email: the user's email
    ///     - size: required download size
    ///     - rating: image rating filtering
    ///
    /// - Returns: Gravatar's URL
    ///
    public static func gravatarUrl(
        with email: String,
        options: GravatarImageDownloadOptions = .init()
    ) -> URL? {
        let hash = gravatarHash(of: email)
        guard let baseURL = URL(string: Defaults.baseURL + hash) else {
            return nil
        }

        return baseURL.addQueryItems(from: options)
    }

    /// Returns the gravatar hash of an email
    ///
    /// - Parameter email: the email associated with the gravatar
    /// - Returns: hashed email
    ///
    /// This really ought to be in a different place, like Gravatar.swift, but there's
    /// lots of duplication around gravatars -nh
    private static func gravatarHash(of email: String) -> String {
        email
            .lowercased()
            .trimmingCharacters(in: .whitespaces)
            .sha256()
    }
}

extension GravatarURL: Equatable {}

public func == (lhs: GravatarURL, rhs: GravatarURL) -> Bool {
    lhs.canonicalURL == rhs.canonicalURL
}

extension GravatarURL {
    public init?(_ url: URL) {
        guard GravatarURL.isGravatarURL(url) else {
            return nil
        }

        guard var components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            return nil
        }

        components.scheme = Defaults.scheme
        components.host = Defaults.host
        components.query = nil

        // Treat unknown@gravatar.com as a nil url
        guard url.lastPathComponent != Defaults.unknownHash else {
            return nil
        }

        guard let sanitizedURL = components.url else {
            return nil
        }

        self.canonicalURL = sanitizedURL
    }
}

extension URL {
    fileprivate func addQueryItems(from options: GravatarImageDownloadOptions) -> URL {
        guard var components = URLComponents(url: self, resolvingAgainstBaseURL: false) else {
            fatalError("Internal error: invalid url")
        }
        components.queryItems = options.queryItems()
        
        if components.queryItems?.isEmpty == true {
            components.queryItems = nil
        }
        
        guard let url = components.url else {
            fatalError("Internal error: invalid url with query items")
        }
        
        return url
    }
}

private enum GravatarImageDownloadOptionQueryName: String, CaseIterable {
    case defaultImage = "d"
    case preferredPixelSize = "s"
    case gravatarRating = "r"
    case forceDefaultImage = "f"
}

private extension GravatarImageDownloadOptions {
    func queryItems() -> [URLQueryItem] {
        let allQueryItems = GravatarImageDownloadOptionQueryName.allCases
            .map { self.queryItem(for: $0) }
        
        let defaultQueryItems = GravatarImageDownloadOptionQueryName.allCases
            .map { GravatarImageDownloadOptions().queryItem(for: $0) }
        
        // Exclude any URLQueryItem whose value is either default or nil.
        return allQueryItems
            .filter { !defaultQueryItems.contains($0) }
            .filter { $0.value != nil }
    }
    
    func queryItem(for queryName: GravatarImageDownloadOptionQueryName) -> URLQueryItem {
        let value: String?
        
        switch queryName {
        case .defaultImage:
            value = self.defaultImage?.rawValue
        case .forceDefaultImage:
            value = String(self.forceDefaultImage)
        case .gravatarRating:
            value = self.gravatarRating?.stringValue()
        case .preferredPixelSize:
            value = String(self.preferredPixelSize)
        }
        
        return URLQueryItem(name: queryName.rawValue, value: value)
    }
}

private extension String {
    init?(_ int: Int?) {
        guard let int = int else { return nil }
        self.init(int)
    }
}
