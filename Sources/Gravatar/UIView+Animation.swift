//
//  File.swift
//  
//
//  Created by Pinar Olguc on 17.01.2024.
//

import Foundation
import UIKit

// MARK: UIKit Constants

class GravatarUIConstants {
    public static let alphaMid: CGFloat = 0.5
    public static let alphaZero: CGFloat = 0
    public static let alphaFull: CGFloat = 1
}

private struct GravatarAnimations {
    static let duration = TimeInterval(0.3)
}

extension UIView {
    /// Applies a fade in animation
    ///
    func fadeInAnimation(_ completion: ((Bool) -> Void)? = nil) {
        alpha = GravatarUIConstants.alphaMid

        UIView.animate(withDuration: GravatarAnimations.duration, animations: { [weak self] in
            self?.alpha = GravatarUIConstants.alphaFull
        }, completion: { success in
            completion?(success)
        })
    }
}
