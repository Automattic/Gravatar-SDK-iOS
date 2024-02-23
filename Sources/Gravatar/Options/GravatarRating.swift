import Foundation

/// Helper Enum that specifies all of the available Gravatar Image Ratings
// TODO: Convert into a pure Swift String Enum. It's done this way to maintain ObjC Compatibility
///
@objc
public enum GravatarRating: Int {
    case g
    case pg
    case r
    case x

    func stringValue() -> String {
        switch self {
        case .g:
            "g"
        case .pg:
            "pg"
        case .r:
            "r"
        case .x:
            "x"
        }
    }
}
