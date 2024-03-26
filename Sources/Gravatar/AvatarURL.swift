import Foundation

public struct AvatarURL {
    public let canonicalUrl: URL
    public let hash: String
    public let url: URL

    let options: AvatarQueryOptions
    let components: URLComponents

    public init?(url: URL, options: AvatarQueryOptions = AvatarQueryOptions()) {
        guard
            Self.isAvatarUrl(url),
            let components = URLComponents(url: url, resolvingAgainstBaseURL: false)?.sanitizingComponents(),
            let sanitizedURL = components.url,
            let url = sanitizedURL.addQueryItems(from: options)
        else {
            return nil
        }

        self.canonicalUrl = sanitizedURL
        self.components = components
        self.hash = sanitizedURL.lastPathComponent
        self.options = options
        self.url = url
    }

    public init?(email: String, options: AvatarQueryOptions = AvatarQueryOptions()) {
        self.init(hash: email.sanitized.sha256(), options: options)
    }

    public init?(hash: String, options: AvatarQueryOptions = AvatarQueryOptions()) {
        guard let url = URL(string: .baseURL + hash) else { return nil }
        self.init(url: url, options: options)
    }

    public static func isAvatarUrl(_ url: URL) -> Bool {
        guard
            let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
            let host = components.host
        else {
            return false
        }

        return (host.hasSuffix(".gravatar.com") || host == "gravatar.com")
            && components.path.hasPrefix("/avatar/")
    }

    public func replacing(options: AvatarQueryOptions) -> AvatarURL? {
        AvatarURL(hash: hash, options: options)
    }
}

extension AvatarURL: Equatable {
    public static func == (lhs: AvatarURL, rhs: AvatarURL) -> Bool {
        lhs.url.absoluteString == rhs.url.absoluteString
    }
}

extension String {
    fileprivate static let scheme = "https"
    fileprivate static let baseURL = "https://gravatar.com/avatar/"
}

extension URL {
    fileprivate func addQueryItems(from options: AvatarQueryOptions) -> URL? {
        guard var components = URLComponents(url: self, resolvingAgainstBaseURL: false) else {
            return nil
        }
        components.queryItems = options.queryItems

        if components.queryItems?.isEmpty == true {
            components.queryItems = nil
        }

        return components.url
    }
}

extension URLComponents {
    fileprivate func sanitizingComponents() -> URLComponents {
        var copy = self
        copy.scheme = .scheme
        copy.query = nil
        return copy
    }
}
