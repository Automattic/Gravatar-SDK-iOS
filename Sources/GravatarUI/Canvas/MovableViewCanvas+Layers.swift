import Foundation
import UIKit

extension MovableViewCanvas {
    func addLayers(_ layers: CanvasLayers, personImage: UIImage) {
        for layer in layers.layers {
            if layer.type == .person {
                let imageView = StylableImageView(id: layer.id, image: personImage)
                imageView.contentMode = .scaleAspectFit
                let aspectRatio = personImage.size.width / personImage.size.height
                let location = layer.position.cgCenterPosition(in: bounds)
                let size = layer.sizeType.cgSize(in: bounds, aspectRatio: aspectRatio, isCropped: layer.isCropped)
                addView(
                    view: imageView,
                    transformations: ViewTransformations(),
                    location: location,
                    size: size,
                    animated: false
                )
            } else {
                addView(layer: layer)
            }
        }
    }

    func addView(
        layer: CanvasLayer
    ) {
        let location = layer.position.cgCenterPosition(in: bounds)
        let size = layer.sizeType.cgSize(in: bounds, aspectRatio: 1, isCropped: layer.isCropped)

        let imageView = StylableImageView(id: layer.id, image: nil)
        imageView.contentMode = .scaleAspectFit
        imageView.frame = CGRect(origin: .zero, size: size)

        switch layer.kind {
        case .color(let hexColor):
            imageView.backgroundColor = hexColor.uiColor
        case .localImage(let name):
            imageView.image = UIImage(named: name)
        case .remoteImage:
            // TODO:
            break
        case .linearGradient(let gradientInfo):
            let colors = gradientInfo.stops.compactMap { stop in
                UIColor(hex: stop.color.hex, alpha: stop.color.alpha)
            }
            let locations = gradientInfo.stops.compactMap { stop in
                NSNumber(floatLiteral: stop.position)
            }
            imageView.applyGradientLayer(
                colors: colors,
                locations: locations,
                startPoint: CGPoint(x: gradientInfo.startPoint.x, y: gradientInfo.startPoint.y),
                endPoint: CGPoint(x: gradientInfo.endPoint.x, y: gradientInfo.endPoint.y)
            )
        case .undetermined:
            break
        case .maskedImage:
            break
        }

        // Add mask if exists
        if let maskImage = layer.createRasterMask(bounds: bounds) {
            let maskLayer = CALayer()
            maskLayer.contents = maskImage.cgImage
            maskLayer.frame = bounds
            imageView.layer.mask = maskLayer
            imageView.layer.masksToBounds = true
        }

        addView(
            view: imageView,
            transformations: ViewTransformations(),
            location: location,
            size: size,
            animated: false
        )
    }
}

extension CanvasLayer: Identifiable {
    var id: String {
        switch type {
        case .background, .person:
            type.rawValue
        case .frame:
            "\(type.rawValue)-\(UUID().uuidString)"
        case .none:
            UUID().uuidString
        }
    }

    func createRasterMask(bounds: CGRect) -> UIImage? {
        guard let maskLayers, !maskLayers.isEmpty else { return nil }
        // 1) Begin a bitmap context
        // UIKit automatically uses the scale factor of the device's main screen when passed 0.0
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, 0.0)
        guard let ctx = UIGraphicsGetCurrentContext() else {
            UIGraphicsEndImageContext()
            return nil
        }
        ctx.setFillColor(UIColor.white.cgColor)

        for maskLayer in maskLayers {
            let size = maskLayer.size
            let position = maskLayer.position
            let maskRect = CGRect(origin: position.cgOriginPosition(in: bounds), size: size.cgSize(in: bounds))

            ctx.setBlendMode(maskLayer.blendMode.cgBlendMode)

            switch maskLayer.kind {
            case .circle:
                let bezierPath = UIBezierPath(
                    arcCenter: position.cgCenterPosition(in: bounds),
                    radius: maskRect.width / 2,
                    startAngle: 0,
                    endAngle: CGFloat.pi * 2,
                    clockwise: true
                )
                ctx.addPath(bezierPath.cgPath)
                ctx.fillPath()

            case .rectangle:
                let bezierPath = UIBezierPath(rect: maskRect)
                ctx.addPath(bezierPath.cgPath)
                ctx.fillPath()

            case .oval:
                let bezierPath = UIBezierPath(ovalIn: maskRect)
                ctx.addPath(bezierPath.cgPath)
                ctx.fillPath()

            case .localImage(let name):
                if let image = UIImage(named: name)?.cgImage {
                    // Fix the image orientation
                    // (CGContext) uses a different coordinate system than UIKit.
                    // Apply a vertical flip transform to the CGContext before drawing the image.
                    ctx.saveGState() // ✅ Save original state before transforming

                    // Flip the context vertically
                    ctx.translateBy(x: 0, y: maskRect.height)
                    ctx.scaleBy(x: 1.0, y: -1.0)

                    // Adjust rect since it's now flipped
                    let flippedRect = CGRect(x: maskRect.origin.x, y: 0, width: maskRect.width, height: maskRect.height)

                    // Draw image in the transformed context
                    ctx.draw(image, in: flippedRect)

                    ctx.restoreGState() // Restore original state
                }

            // ctx.fillPath() ?
            case .roundedRectangle(let cornerRadii, let roundCorners):
                let centerPoint = position.cgCenterPosition(in: bounds)
                let size = size.cgSize(in: bounds)
                let originX = centerPoint.x - (size.width * 0.5)
                let originyY = centerPoint.y - (size.height * 0.5)

                let bezierPath = UIBezierPath(
                    roundedRect: .init(x: originX, y: originyY, width: size.width, height: size.height),
                    byRoundingCorners: UIRectCorner(strings: roundCorners),
                    cornerRadii: cornerRadii.cgSize(in: maskRect)
                )
                ctx.addPath(bezierPath.cgPath)
                ctx.fillPath()

            case .remoteImage:
                // TODO:
                break
            }
        }
        guard let maskImage = UIGraphicsGetImageFromCurrentImageContext() else {
            UIGraphicsEndImageContext()
            return nil
        }
        UIGraphicsEndImageContext()

        return maskImage
    }
}

extension CanvasLayer.SizeType {
    func cgSize(in bounds: CGRect, aspectRatio: CGFloat, isCropped: Bool) -> CGSize {
        switch self {
        case .normal(let size):
            return size.cgSize(in: bounds)
        case .intrinsicSize(let intrinsicSize):
            var size: CGSize
            if isCropped {
                if aspectRatio > 1 {
                    let adjustedWidth = intrinsicSize.ratio * bounds.width
                    size = .init(width: adjustedWidth, height: adjustedWidth / aspectRatio)
                } else {
                    let adjustedHeight = intrinsicSize.ratio * bounds.height
                    size = .init(width: adjustedHeight * aspectRatio, height: adjustedHeight)
                }
            } else {
                if aspectRatio > 1 {
                    let adjustedHeight = intrinsicSize.ratio * bounds.height
                    size = .init(width: adjustedHeight * aspectRatio, height: adjustedHeight)
                } else {
                    let adjustedWidth = intrinsicSize.ratio * bounds.width
                    size = .init(width: adjustedWidth, height: adjustedWidth / aspectRatio)
                }
            }

            return size
        }
    }
}

extension Position {
    func cgCenterPosition(in bounds: CGRect) -> CGPoint {
        switch kind {
        case .center(let point):
            return point.cgPoint(in: bounds)
        case .origin(let point):
            let cgPoint = point.cgPoint(in: bounds)
            let x = cgPoint.x + (bounds.width * 0.5)
            let y = cgPoint.y + (bounds.height * 0.5)
            return CGPoint(x: x, y: y)
        }
    }

    func cgOriginPosition(in bounds: CGRect) -> CGPoint {
        switch kind {
        case .center(let point):
            let cgPoint = point.cgPoint(in: bounds)
            let x = cgPoint.x - (bounds.width * 0.5)
            let y = cgPoint.y - (bounds.height * 0.5)
            return CGPoint(x: x, y: y)
        case .origin(let point):
            return point.cgPoint(in: bounds)
        }
    }
}

extension Size2D {
    func cgSize(in bounds: CGRect) -> CGSize {
        CGSize(width: bounds.width * CGFloat(width), height: bounds.height * CGFloat(height))
    }
}

extension Point {
    func cgPoint(in bounds: CGRect) -> CGPoint {
        let newX = (bounds.minX + x * bounds.width)
        let newY = (bounds.minY + y * bounds.height)
        return CGPoint(x: newX, y: newY)
    }
}

extension HexColor {
    var uiColor: UIColor? {
        UIColor(hex: hex, alpha: alpha)
    }
}

extension UIColor {
    /// Create a UIColor from a 6-digit hex string (e.g. "FF0000") and an optional alpha.
    /// Returns nil if the hex string is not exactly 6 characters or invalid hex.
    convenience init?(hex: String, alpha: CGFloat = 1.0) {
        // Ensure correct length
        guard hex.count == 6 else { return nil }

        // Convert hex string to an integer
        var rgbValue: UInt64 = 0
        let scanner = Scanner(string: hex)

        guard scanner.scanHexInt64(&rgbValue) else {
            return nil
        }

        // Extract RGB components
        let r = (rgbValue & 0xFF0000) >> 16
        let g = (rgbValue & 0x00FF00) >> 8
        let b = rgbValue & 0x0000FF

        self.init(
            red: CGFloat(r) / 255.0,
            green: CGFloat(g) / 255.0,
            blue: CGFloat(b) / 255.0,
            alpha: alpha
        )
    }
}

extension UIRectCorner {
    /// Initializes a UIRectCorner from an optional list of corner strings.
    /// If the array is nil or empty, defaults to .allCorners.
    /// Supported strings: "topLeft", "topRight", "bottomLeft", "bottomRight".
    init(strings: [String]?) {
        guard let strings else {
            self = .allCorners
            return
        }

        var corners: UIRectCorner = []
        for corner in strings {
            switch corner {
            case "topLeft":
                corners.insert(.topLeft)
            case "topRight":
                corners.insert(.topRight)
            case "bottomLeft":
                corners.insert(.bottomLeft)
            case "bottomRight":
                corners.insert(.bottomRight)
            default:
                break
            }
        }

        // If no valid strings found, default to all corners
        self = corners.isEmpty ? .allCorners : corners
    }
}

extension MaskBlendMode {
    var cgBlendMode: CGBlendMode {
        switch self {
        case .normal:
            .normal
        case .clear:
            .clear
        }
    }
}
