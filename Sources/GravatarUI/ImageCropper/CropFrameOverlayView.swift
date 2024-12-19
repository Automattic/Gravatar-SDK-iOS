import UIKit

class CropFrameOverlayView: UIView {
    var scrollViewFrame: CGRect = .zero {
        didSet {
            setNeedsDisplay()
        }
    }

    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }

        // Fill the entire view with a semi black color
        context.setFillColor(UIColor.black.withAlphaComponent(0.5).cgColor)
        context.fill(rect)

        // Create a circular path for the transparent hole
        let circlePath = UIBezierPath(ovalIn: scrollViewFrame)

        // Clear the circular area
        context.addPath(circlePath.cgPath)
        context.clip(using: .evenOdd)
        context.clear(scrollViewFrame)

        // Restore context to draw the square border
        context.resetClip()

        // Draw a white border around the square
        context.setStrokeColor(UIColor.white.cgColor)
        context.setLineWidth(1)
        context.stroke(scrollViewFrame)
    }
}
