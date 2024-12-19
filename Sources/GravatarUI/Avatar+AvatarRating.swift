extension Avatar {
    /// Transforms `Avatar.Rating` into `AvatarRating`
    /// This is only necessary while we maintain both enums.  For our next major realease, `Avatar` will use the `AvatarRating` enum
    /// rather than defining its own.
    var avatarRating: AvatarRating {
        switch self.rating {
        case .g: .g
        case .pg: .pg
        case .r: .r
        case .x: .x
        }
    }
}
