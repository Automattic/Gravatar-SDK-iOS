import UIKit

extension UIColor {
    // A way to create dynamic colors
    convenience init(light: UIColor, dark: UIColor) {
        self.init { traitCollection in
            if traitCollection.userInterfaceStyle == .dark {
                dark
            } else {
                light
            }
        }
    }
}

extension UIColor {
    // Generated names are from https://colornamer.robertcooper.me/
    static let gravatarBlack: UIColor = .rgba(16, 21, 23)
    static let snowflakeWhite: UIColor = .rgba(240, 240, 240)
    static let porpoiseGray: UIColor = .rgba(218, 218, 218)
    static let snowflakeWhite60: UIColor = snowflakeWhite.withAlphaComponent(0.6)
    static let dugongGray: UIColor = .rgba(112, 112, 112)

    static func rgba(_ red: CGFloat, _ green: CGFloat, _ blue: CGFloat, alpha: CGFloat = 1.0) -> UIColor {
        UIColor(red: red / 255, green: green / 255, blue: blue / 255, alpha: alpha)
    }
}