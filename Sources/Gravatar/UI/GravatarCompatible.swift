//
//  GravatarCompatible.swift
//
//
//  Created by Pinar Olguc on 18.01.2024.
//

import Foundation
import UIKit

// Collects all Gravatar methods together.
public struct GravatarWrapper<Component> {
    public let component: Component
    public init(_ component: Component) {
        self.component = component
    }
}

public protocol GravatarCompatible: AnyObject { }

extension GravatarCompatible {
    /// Returns a wrapper that provides Gravatar's convenience methods and properties.
    public var gravatar: GravatarWrapper<Self> {
        get { return GravatarWrapper(self) }
        set { }
    }
}

extension UIImageView: GravatarCompatible { }
