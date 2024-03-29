/// Options to return a default avatar if the avatar requested does not exist.
/// Most of these work by taking the requested email hash and using it to generate a themed image that is unique to that email address.
///
public enum DefaultAvatarOption: String {
    /// Return an HTTP 404 (File Not Found) response error if the avatar is not found.
    case status404 = "404"
    /// A simple, cartoon-style silhouetted outline of a person (does not vary by email hash).
    case mysteryPerson = "mp"
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

extension DefaultAvatarOption: CaseIterable {}
