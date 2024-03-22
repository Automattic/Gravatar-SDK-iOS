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

    public func url(with options: ImageQueryOptions) -> URL {
        // When `GravatarURL` is initialized successfully, the `canonicalURL` is a valid URL.
        // Adding query items from the options, which is controlled by the SDK, should never
        // result in an invalid URL. If it does, something terrible has happened.
        guard let url = canonicalURL.addQueryItems(from: options) else {
            fatalError("Internal error: invalid url with query items")
        }

        return url
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
        with avatarId: AvatarIdentifier,
        options: ImageQueryOptions = .init()
    ) -> URL? {
        guard let baseURL = URL(string: Defaults.baseURL + avatarId.identifier) else {
            return nil
        }

        return baseURL.addQueryItems(from: options)
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
