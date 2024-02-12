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
            return "g"
        case .pg:
            return "pg"
        case .r:
            return "r"
        case .x:
            return "x"
        }
    }
}
