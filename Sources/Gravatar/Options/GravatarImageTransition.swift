//
//  ImageTransition.swift
//  
//
//  Created by Pinar Olguc on 23.01.2024.
//

import Foundation

public enum GravatarImageTransition {
    /// No animation transition.
    case none
    /// Fade in the loaded image in a given duration.
    case fade(TimeInterval)
}

extension GravatarImageTransition: Equatable { }
