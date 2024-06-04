import Foundation
import UIKit

@MainActor
extension UIFont {
    /// Whether to adjust the font size according to the system's font size settings. Default: `true`.
    public static var isGravatarDynamicFontSizeEnabled: Bool = true

    // Point values noted here comes from the "Large (Default)" column of the
    // Specification: https://developer.apple.com/design/human-interface-guidelines/typography#Specifications
    // Note: These are dynamic sized fonts so the real size will vary.
    @MainActor
    enum DS {
        static var largeTitle: UIFont { DynamicFontHelper.font(forTextStyle: .largeTitle, weight: .bold) } // 34pt
        static var title1: UIFont { DynamicFontHelper.font(forTextStyle: .title1, weight: .bold) } // 28pt
        static var title2: UIFont { DynamicFontHelper.font(forTextStyle: .title2, weight: .bold) } // 22pt
        static var title3: UIFont { DynamicFontHelper.font(forTextStyle: .title3, weight: .semibold) } // 20pt
        static var headline: UIFont { DynamicFontHelper.font(forTextStyle: .headline, weight: .bold) } // 17pt

        @MainActor
        enum Body {
            static var large: UIFont { DynamicFontHelper.font(forTextStyle: .body, weight: .regular) } // 17pt
            static var medium: UIFont { DynamicFontHelper.font(forTextStyle: .callout, weight: .regular) } // 16pt
            static var small: UIFont { DynamicFontHelper.font(forTextStyle: .subheadline, weight: .regular) } // 15pt
            static var xSmall: UIFont { DynamicFontHelper.font(forTextStyle: .footnote, weight: .regular) } // 13pt

            @MainActor
            enum Emphasized {
                static var large: UIFont { DynamicFontHelper.font(forTextStyle: .body, weight: .semibold) } // 17pt
                static var medium: UIFont { DynamicFontHelper.font(forTextStyle: .callout, weight: .semibold) } // 16pt
                static var small: UIFont { DynamicFontHelper.font(forTextStyle: .subheadline, weight: .semibold) } // 15pt
            }
        }

        static var footnote: UIFont { DynamicFontHelper.font(forTextStyle: .footnote, weight: .regular) } // 13pt
        static var caption: UIFont { DynamicFontHelper.font(forTextStyle: .caption1, weight: .regular) } // 12pt
    }
}

private enum DynamicFontHelper {
    @MainActor
    static func font(forTextStyle style: UIFont.TextStyle, weight: UIFont.Weight) -> UIFont {
        var fontDescriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: style)
        let traits = [UIFontDescriptor.TraitKey.weight: weight]
        fontDescriptor = fontDescriptor.addingAttributes([.traits: traits])
        let font = UIFont(descriptor: fontDescriptor, size: CGFloat(0))

        if UIFont.isGravatarDynamicFontSizeEnabled {
            return UIFontMetrics.default.scaledFont(for: font)
        }
        return font
    }
}
