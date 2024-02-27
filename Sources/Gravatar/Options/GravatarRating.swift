import Foundation

// TODO: Convert into a pure Swift String Enum. It's done this way to maintain ObjC Compatibility

@objc
/// Gravatar allows users to self-rate their images so that they can indicate if an image is appropriate for a certain audience. By default, only `G` rated images are displayed unless you indicate that you would like to see higher ratings.
///
/// If the requested email hash does not have an image meeting the requested rating level, then the default image is returned (See: ``DefaultImageOption``)
public enum GravatarRating: Int {
    /// Suitable for display on all websites with any audience type.
    case g
    /// May contain rude gestures, provocatively dressed individuals, the lesser swear words, or mild violence.
    case pg
    /// May contain such things as harsh profanity, intense violence, nudity, or hard drug use.
    case r
    /// May contain sexual imagery or extremely disturbing violence.
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
