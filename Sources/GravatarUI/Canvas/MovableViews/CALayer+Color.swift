import Foundation
import UIKit

/// Extension that extracts a color from a given point
extension CALayer {
    func getColor(from point: CGPoint, defaultColor: UIColor = .black) -> UIColor {
        var pixel: [CUnsignedChar] = [0, 0, 0, 0]

        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)

        guard let context = CGContext(
            data: &pixel,
            width: 1,
            height: 1,
            bitsPerComponent: 8,
            bytesPerRow: 4,
            space: colorSpace,
            bitmapInfo: bitmapInfo.rawValue
        ) else {
            return defaultColor
        }

        context.translateBy(x: -point.x, y: -point.y)

        render(in: context)

        let red = CGFloat(pixel[0]) / 255.0
        let green = CGFloat(pixel[1]) / 255.0
        let blue = CGFloat(pixel[2]) / 255.0
        let alpha = CGFloat(pixel[3]) / 255.0

        return UIColor(red: red, green: green, blue: blue, alpha: alpha)
    }
}
