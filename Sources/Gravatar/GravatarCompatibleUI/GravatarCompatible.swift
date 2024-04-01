import Foundation
import UIKit

/// Wrapper for `GravatarCompatible`  types.
public struct GravatarWrapper<Component> {
    public let component: Component
    public init(_ component: Component) {
        self.component = component
    }
}

public protocol GravatarCompatible: AnyObject {}

/// Provides namespacing for the Gravatar functionality.
extension GravatarCompatible {
    /// Returns a wrapper that provides Gravatar's convenience methods and properties.
    public var gravatar: GravatarWrapper<Self> {
        get { GravatarWrapper(self) }
        set {}
    }
}

extension UIImageView: GravatarCompatible {}
extension UILabel: GravatarCompatible {}
