import Foundation

public enum GravatarImageTransition {
    /// No animation transition.
    case none
    /// Fade in the loaded image in a given duration.
    case fade(TimeInterval)
}

extension GravatarImageTransition: Equatable {}
