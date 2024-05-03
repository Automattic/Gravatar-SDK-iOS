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

    func hexString() -> String {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        self.getRed(&r, green: &g, blue: &b, alpha: &a)
        let rgb = Int(r * 255) << 16 | Int(g * 255) << 8 | Int(b * 255) << 0
        return String(format: "#%06x", rgb)
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
    static let orchidBlack: UIColor = .rgba(80, 87, 94)

    static func rgba(_ red: CGFloat, _ green: CGFloat, _ blue: CGFloat, alpha: CGFloat = 1.0) -> UIColor {
        UIColor(red: red / 255, green: green / 255, blue: blue / 255, alpha: alpha)
    }
}
