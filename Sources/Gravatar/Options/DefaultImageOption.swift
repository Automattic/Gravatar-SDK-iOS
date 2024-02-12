/// Options to return a default image if the image requested does not exist.
/// Most of these work by taking the requested email hash and using it to generate a themed image that is unique to that email address.
///
public enum DefaultImageOption: String {
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

extension DefaultImageOption: CaseIterable {}
