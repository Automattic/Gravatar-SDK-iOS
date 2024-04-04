import Foundation

/// Options to return a default avatar if the avatar requested does not exist.
/// Most of these work by taking the requested email hash and using it to generate a themed image that is unique to that email address.
///
public enum DefaultAvatarOption {
    /// Return an HTTP 404 (File Not Found) response error if the avatar is not found.
    case status404
    /// A simple, cartoon-style silhouetted outline of a person (does not vary by email hash).
    case mysteryPerson
    /// A geometric pattern based on an email hash.
    case identicon
    /// A generated ‘monster’ with different colors, faces, etc.
    case monsterId
    /// Fenerated faces with differing features and backgrounds.
    case wavatar
    /// Awesome generated, 8-bit arcade-style pixelated faces
    case retro
    /// A generated robot with different colors, faces, etc
    case roboHash
    /// A transparent PNG image
    case transparentPNG
    /// If you prefer to use your own default image (perhaps your logo, a funny face, whatever), then you can easily do so by using the CustomUrl option and supplying the URL to an image.
    ///
    /// - Rating and size parameters are ignored when the custom default is set.
    /// - There are a few conditions which must be met for default image URL:
    ///   * **MUST** be publicly available (e.g. cannot be on an intranet, on a local development machine, behind HTTP Auth or some other firewall etc). Default images are passed through a security scan to avoid malicious content.
    ///   * **MUST** be accessible via HTTP or HTTPS on the standard ports, 80 and 443, respectively.
    ///   * **MUST** have a recognizable image extension (jpg, jpeg, gif, png, heic)
    ///   * **MUST NOT** include a querystring (if it does, it will be ignored)
    /// - Parameter url: The custom URL of the image to use as the default avatar image.
    case customURL(URL)
}

extension DefaultAvatarOption {
    var rawValue: String {
        switch self {
        case .status404:
            "404"
        case .mysteryPerson:
            "mp"
        case .identicon:
            "identicon"
        case .monsterId:
            "monsterid"
        case .wavatar:
            "wavatar"
        case .retro:
            "retro"
        case .roboHash:
            "robohash"
        case .transparentPNG:
            "blank"
        case .customURL(let url):
            url.absoluteString
        }
    }
}

extension DefaultAvatarOption: CaseIterable {
    public static var allCases: [DefaultAvatarOption] {
        [.status404, .mysteryPerson, .identicon, .monsterId, .wavatar, .retro, .roboHash, .transparentPNG]
    }
}
