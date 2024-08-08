import Foundation
import SwiftUI

@MainActor
class ProfileViewPlaceholderColorManager: ObservableObject {
    @Published private var backgroundColorIndex = 0
    @Published private var shouldAnimatePlaceholderColors = false

    // This is `@Published` because we want the observing view to re-render when this changes.
    @Published var colorScheme: ColorScheme = .light

    func toggleAnimation(_ shouldAnimate: Bool) {
        if shouldAnimate {
            startAnimation()
        } else {
            stopAnimation()
        }
    }

    var placeholderColor: Color {
        shouldAnimatePlaceholderColors ? animatingPlaceholderColor : primaryPlaceholderColor
    }

    private var palette: Palette {
        colorScheme == .dark ? PaletteType.dark.palette : PaletteType.light.palette
    }

    private func startAnimation() {
        withAnimation(Animation.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) {
            shouldAnimatePlaceholderColors = true
            incrementBackgroundColorIndex()
        }
    }

    private func stopAnimation() {
        withAnimation(Animation.easeOut(duration: 0.3)) {
            shouldAnimatePlaceholderColors = false
            backgroundColorIndex = 0
        }
    }

    private var primaryPlaceholderColor: Color {
        Color(palette.placeholder.backgroundColor)
    }

    private var animatingPlaceholderColor: Color {
        guard let uiColor = palette.placeholder.loadingAnimationColors[safe: backgroundColorIndex] else {
            return .clear
        }
        return Color(uiColor: uiColor)
    }

    private func incrementBackgroundColorIndex() {
        let colors = palette.placeholder.loadingAnimationColors
        backgroundColorIndex = (backgroundColorIndex + 1) % colors.count
    }
}
