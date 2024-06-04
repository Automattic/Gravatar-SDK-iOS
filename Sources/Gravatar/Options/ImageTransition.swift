import Foundation

public enum ImageTransition: Sendable {
    /// No animation transition.
    case none
    /// Fade in the loaded image in a given duration.
    case fade(TimeInterval)
}

extension ImageTransition: Equatable {}
