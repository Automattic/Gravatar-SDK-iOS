import Foundation

public struct AvatarURL {
    public let canonicalURL: URL
    public let hash: String
    public let url: URL

    let options: AvatarQueryOptions
    let components: URLComponents

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

    public init?(with avatarID: AvatarIdentifier, options: AvatarQueryOptions = AvatarQueryOptions()) {
        guard let url = URL(string: .baseURL + avatarID.id) else { return nil }
        self.init(url: url, options: options)
    }

    public static func isAvatarURL(_ url: URL) -> Bool {
        url.isGravatarURL && url.path.hasPrefix("/avatar/")
    }

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
