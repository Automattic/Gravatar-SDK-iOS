import Foundation

/// A type that represents a canonical Gravatar avatar URL along with associated options and metadata.
public struct AvatarURL {
    /// The sanitized canonical URL without any query parameters.
    public let canonicalURL: URL
    /// The unique hash string used to identify the Gravatar.
    public let hash: String
    /// The full Gravatar URL including any query parameters based on provided options.
    public let url: URL

    let options: AvatarQueryOptions
    let components: URLComponents

    /// Initializes a new `AvatarURL` from a given URL and optional query options.
    ///
    /// This initializer validates the input URL to ensure it is a proper Gravatar avatar URL.
    /// It also applies any provided `AvatarQueryOptions` to the resulting URL.
    ///
    /// - Parameters:
    ///   - url: A potential Gravatar avatar URL.
    ///   - options: Optional query options to apply to the URL.
    /// - Returns: A valid `AvatarURL` if the input URL is recognized as a Gravatar avatar URL; otherwise, `nil`.
    public init?(url: URL, options: AvatarQueryOptions = AvatarQueryOptions()) {
        guard
            Self.isAvatarURL(url),
            let sanitizedComponents = URLComponents(url: url, resolvingAgainstBaseURL: false)?.sanitizingComponents(),
            let sanitizedURL = sanitizedComponents.url
        else {
            return nil
        }

        let components = sanitizedComponents.settingQueryItems(options.queryItems, shouldEncodePlusChar: true)

        guard let url = components.url else { return nil }

        self.canonicalURL = sanitizedURL
        self.components = components
        self.hash = sanitizedURL.lastPathComponent
        self.options = options
        self.url = url
    }

    /// Initializes a new `AvatarURL` from an `AvatarIdentifier` and optional query options.
    ///
    /// - Parameters:
    ///   - avatarID: An identifier representing the Gravatar user.
    ///   - options: Optional query options to apply to the URL.
    /// - Returns: A valid `AvatarURL` if the identifier is valid and the URL can be constructed; otherwise, `nil`.
    public init?(with avatarID: AvatarIdentifier, options: AvatarQueryOptions = AvatarQueryOptions()) {
        guard let url = URL(string: .baseURL + avatarID.id) else { return nil }
        self.init(url: url, options: options)
    }

    /// Determines whether the given URL points to a Gravatar avatar.
    ///
    /// - Parameter url: The URL to validate.
    /// - Returns: `true` if the URL is a valid Gravatar avatar URL.
    public static func isAvatarURL(_ url: URL) -> Bool {
        url.isGravatarURL && url.path.hasPrefix("/avatar/")
    }

    /// Returns a new `AvatarURL` for the same Gravatar with a new set of query options.
    ///
    /// - Parameter options: The new query options to apply.
    /// - Returns: A new `AvatarURL` with the updated options, or `nil` if construction fails.
    public func replacing(options: AvatarQueryOptions) -> AvatarURL? {
        AvatarURL(with: .hashID(self.hash), options: options)
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

extension URLComponents {
    fileprivate func sanitizingComponents() -> URLComponents {
        var copy = self
        copy.scheme = .scheme
        copy.query = nil
        return copy
    }
}
