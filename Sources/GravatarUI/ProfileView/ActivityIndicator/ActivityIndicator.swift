import UIKit

/// Describes a general purpose activity indicator.
@MainActor
public protocol ActivityIndicator {
    associatedtype T: UIView
    func startAnimating(on baseView: T)
    func stopAnimating(on baseView: T)
}
