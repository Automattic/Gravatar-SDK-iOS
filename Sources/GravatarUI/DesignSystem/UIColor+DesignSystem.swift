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
    static let bleachedSilkWhite: UIColor = .rgba(242, 242, 242)
    static let smokeWhite: UIColor = .rgba(229, 231, 233)
    static let snowflakeWhite60: UIColor = snowflakeWhite.withAlphaComponent(0.6)
    static let boatAnchorGray: UIColor = .rgba(107, 107, 107)
    static let spanishGray: UIColor = .rgba(151, 151, 151)
    static let dugongGray: UIColor = .rgba(112, 112, 112)

    static func rgba(_ red: CGFloat, _ green: CGFloat, _ blue: CGFloat, alpha: CGFloat = 1.0) -> UIColor {
        UIColor(red: red / 255, green: green / 255, blue: blue / 255, alpha: alpha)
    }
}
