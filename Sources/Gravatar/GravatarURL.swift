import Foundation

public struct GravatarURL {
    fileprivate struct Defaults {
        static let scheme = "https"
        static let host = "secure.gravatar.com"
        static let unknownHash = "ad516503a11cd5ca435acc9bb6523536"
        static let baseURL = "https://gravatar.com/avatar"
        static let imageSize = 80
    }

    let canonicalURL: URL

    public func urlWithSize(_ size: Int, defaultImage: DefaultImageOption? = nil) -> URL {
        var components = URLComponents(url: canonicalURL, resolvingAgainstBaseURL: false)!
        components.query = "s=\(size)&d=\(defaultImage?.rawValue ?? DefaultImageOption.defaultOption.rawValue)"
        return components.url!
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
        for email: String,
        defaultImage: DefaultImageOption? = nil,
        size: Int? = nil,
        rating: GravatarRating = .default) -> URL?
    {
        let hash = gravatarHash(of: email)
        let targetURL = String(format: "%@/%@?d=%@&s=%d&r=%@",
            Defaults.baseURL,
            hash,
            defaultImage?.rawValue ?? DefaultImageOption.fileNotFound.rawValue,
            size ?? Defaults.imageSize,
            rating.stringValue()
        )
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
        return (try? email
            .lowercased()
            .trimmingCharacters(in: .whitespaces)
            .sha256()) ?? ""
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

/// Options to return a default image if the image requested does not exist.
/// Most of these work by taking the requested email hash and using it to generate a themed image that is unique to that email address.
///
public enum DefaultImageOption: String {
    public static let defaultOption: DefaultImageOption = .fileNotFound
    /// Return an HTTP 404 (File Not Found) response error if the image is not found.
    case fileNotFound = "404"
    /// A simple, cartoon-style silhouetted outline of a person (does not vary by email hash).
    case misteryPerson = "mp"
    /// A geometric pattern based on an email hash.
    case identicon
    /// A generated ‘monster’ with different colors, faces, etc.
    case monsterId = "monsterid"
    /// Fenerated faces with differing features and backgrounds.
    case wavatar
    /// Awesome generated, 8-bit arcade-style pixelated faces
    case retro
    /// A generated robot with different colors, faces, etc
    case roboHash = "robohash"
    /// A transparent PNG image
    case transparentPNG = "blank"
}
