import Foundation
import UIKit

extension UIFont {
    /// Whether to adjust the font size according to the system's font size settings. Default: `true`.
    public static var isDynamicTypeEnabled: Bool = true

    // Specifications: https://developer.apple.com/design/human-interface-guidelines/typography#Specifications
    enum DS {
        static var largeTitle: UIFont { DynamicFontHelper.fontForTextStyle(.largeTitle, fontWeight: .bold) } // 34pt
        static var title1: UIFont { DynamicFontHelper.fontForTextStyle(.title1, fontWeight: .bold) } // 28pt
        static var title2: UIFont { DynamicFontHelper.fontForTextStyle(.title2, fontWeight: .bold) } // 22pt
        static var title3: UIFont { DynamicFontHelper.fontForTextStyle(.title3, fontWeight: .semibold) } // 20pt

        enum Body {
            static var small: UIFont { DynamicFontHelper.fontForTextStyle(.subheadline, fontWeight: .regular) } // 15pt
            static var medium: UIFont { DynamicFontHelper.fontForTextStyle(.callout, fontWeight: .regular) } // 16pt
            static var large: UIFont { DynamicFontHelper.fontForTextStyle(.body, fontWeight: .regular) } // 17pt

            enum Emphasized {
                static var small: UIFont { DynamicFontHelper.fontForTextStyle(.subheadline, fontWeight: .semibold) } // 15pt
                static var medium: UIFont { DynamicFontHelper.fontForTextStyle(.callout, fontWeight: .semibold) } // 16pt
                static var large: UIFont { DynamicFontHelper.fontForTextStyle(.body, fontWeight: .semibold) } // 17pt
            }
        }

        static var footnote: UIFont { DynamicFontHelper.fontForTextStyle(.footnote, fontWeight: .regular) } // 13pt
        static var caption: UIFont { DynamicFontHelper.fontForTextStyle(.caption1, fontWeight: .regular) } // 12pt
    }
}

private enum DynamicFontHelper {
    static func fontForTextStyle(_ style: UIFont.TextStyle, fontWeight weight: UIFont.Weight) -> UIFont {
        var fontDescriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: style)
        let traits = [UIFontDescriptor.TraitKey.weight: weight]
        fontDescriptor = fontDescriptor.addingAttributes([.traits: traits])
        let font = UIFont(descriptor: fontDescriptor, size: CGFloat(0.0))

        if UIFont.isDynamicTypeEnabled {
            return UIFontMetrics.default.scaledFont(for: font)
        }
        return font
    }
}
