import Foundation

public struct AvatarURL {
    public let canonicalUrl: URL
    public let hash: String

    let options: ImageQueryOptions
    var components: URLComponents

    public var url: URL {
        // When `AavatarURL` is initialized successfully, the `canonicalUrl` field is a valid URL.
        // Adding query items from the options, which is controlled by the SDK, should never
        // result in an invalid URL. If it does, something terrible has happened.
        guard let url = canonicalUrl.addQueryItems(from: options) else {
            fatalError("Internal error: invalid url with query items")
        }

        return url
    }

    public init?(url: URL, options: ImageQueryOptions = ImageQueryOptions()) {
        guard
            Self.isAvatarUrl(url),
            let components = URLComponents(url: url, resolvingAgainstBaseURL: false)?.sanitizedComponents(),
            let sanitizedURL = components.url
        else {
            return nil
        }

        self.canonicalUrl = sanitizedURL
        self.components = components
        self.hash = sanitizedURL.lastPathComponent
        self.options = options
    }

    public init?(email: String, options: ImageQueryOptions = ImageQueryOptions()) {
        self.init(hash:  email.sanitized.sha256(), options: options)
    }

    public init?(hash: String, options: ImageQueryOptions = ImageQueryOptions()){
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

    public func updating(options: ImageQueryOptions) -> AvatarURL {
        guard let avatarUrl = AvatarURL(hash: hash, options: options) else {
            // When `AavatarURL` is initialized successfully, is guaranteed to be a valid URL.
            // Adding query items from the options, which is controlled by the SDK, should never
            // result in an invalid URL. If it does, something terrible has happened.
            fatalError("Internal error: invalid url with query items")
        }
        return avatarUrl
    }
}

extension AvatarURL: Equatable {
    public static func == (lhs: AvatarURL, rhs: AvatarURL) -> Bool {
        lhs.url.absoluteString == rhs.url.absoluteString
    }
}

private extension String {
    static let baseURL = "https://gravatar.com/avatar/"
}

extension String {
    var sanitized: String {
        self.lowercased()
            .trimmingCharacters(in: .whitespaces)
    }
}

extension URL {
    fileprivate func addQueryItems(from options: ImageQueryOptions) -> URL? {
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
