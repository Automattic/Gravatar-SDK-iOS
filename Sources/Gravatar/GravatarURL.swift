import Foundation

/// Helper Enum that specifies some of the options for default images
/// To see all available options, visit : https://en.gravatar.com/site/implement/images/
///
public enum GravatarDefaultImage: String {
    case fileNotFound = "404"
    case mp
    case identicon
}

public struct GravatarURL {
    fileprivate struct Defaults {
        static let scheme = "https"
        static let host = "secure.gravatar.com"
        static let unknownHash = "ad516503a11cd5ca435acc9bb6523536"
        static let baseURL = "https://gravatar.com/avatar"
        static let imageSize = 80
    }

    public let canonicalURL: URL

    public func urlWithSize(_ size: Int, defaultImage: GravatarDefaultImage? = nil) -> URL {
        var components = URLComponents(url: canonicalURL, resolvingAgainstBaseURL: false)!
        components.query = "s=\(size)&d=\(defaultImage?.rawValue ?? GravatarDefaultImage.fileNotFound.rawValue)"
        return components.url!
    }

    public static func isGravatarURL(_ url: URL) -> Bool {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            return false
        }

        guard let host = components.host, host.hasSuffix(".gravatar.com") else {
                return false
        }

        guard url.path.hasPrefix("/avatar/") else {
                return false
        }

        return true
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
    public static func gravatarUrl(for email: String,
                                   defaultImage: GravatarDefaultImage? = nil,
                                   size: Int? = nil,
                                   rating: GravatarRating = .default) -> URL? {
        let hash = gravatarHash(of: email)
        let targetURL = String(format: "%@/%@?d=%@&s=%d&r=%@",
                               Defaults.baseURL,
                               hash,
                               defaultImage?.rawValue ?? GravatarDefaultImage.fileNotFound.rawValue,
                               size ?? Defaults.imageSize,
                               rating.stringValue())
        return URL(string: targetURL)
    }

    /// Returns the gravatar hash of an email
    ///
    /// - Parameter email: the email associated with the gravatar
    /// - Returns: hashed email
    ///
    /// This really ought to be in a different place, like Gravatar.swift, but there's
    /// lots of duplication around gravatars -nh
    private static func gravatarHash(of email: String) -> String {
        return email
            .lowercased()
            .trimmingCharacters(in: .whitespaces)
            .sha256() ?? ""
    }
}

extension GravatarURL: Equatable {}

public func ==(lhs: GravatarURL, rhs: GravatarURL) -> Bool {
    return lhs.canonicalURL == rhs.canonicalURL
}

public extension GravatarURL {
    init?(_ url: URL) {
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
