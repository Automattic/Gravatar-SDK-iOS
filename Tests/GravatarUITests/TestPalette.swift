import GravatarUI
import UIKit

extension Palette {
    static func testPalette() -> Palette {
        Palette(
            name: "TestPalette",
            foreground: ForegroundColors(
                primary: UIColor(red: 90 / 255, green: 88 / 255, blue: 88 / 255, alpha: 1),

                primarySlightlyDimmed: UIColor(red: 90 / 255, green: 88 / 255, blue: 88 / 255, alpha: 0.7),
                secondary: UIColor(red: 9 / 255, green: 93 / 255, blue: 154 / 255, alpha: 1)
            ),
            background: BackgroundColors(primary: UIColor(red: 251 / 255, green: 216 / 255, blue: 183 / 255, alpha: 1)),
            avatar: AvatarColors(
                border: UIColor(red: 9 / 255, green: 93 / 255, blue: 154 / 255, alpha: 1),
                background: UIColor(red: 9 / 255, green: 93 / 255, blue: 154 / 255, alpha: 0.25),
                tint: UIColor(red: 9 / 255, green: 93 / 255, blue: 154 / 255, alpha: 1)
            ),
            border: UIColor(red: 255 / 255, green: 99 / 255, blue: 137 / 255, alpha: 1),
            placeholder: PlaceholderColors(
                backgroundColor: UIColor(red: 255 / 255, green: 179 / 255, blue: 186 / 255, alpha: 1),
                loadingAnimationColors: [UIColor(red: 255 / 255, green: 179 / 255, blue: 186 / 255, alpha: 1),
                                         UIColor(red: 255 / 255, green: 223 / 255, blue: 186 / 255, alpha: 1)]
            ),
            preferredUserInterfaceStyle: .light
        )
    }
}
