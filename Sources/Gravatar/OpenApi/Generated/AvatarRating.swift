import Foundation

/// Rating associated with the image.
///
package enum AvatarRating: String, Codable, CaseIterable {
    case g = "G"
    case pg = "PG"
    case r = "R"
    case x = "X"
}
