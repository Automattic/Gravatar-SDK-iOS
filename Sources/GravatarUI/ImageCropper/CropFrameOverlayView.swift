import UIKit

class CropFrameOverlayView: UIView {
    var scrollViewFrame: CGRect = .zero {
        didSet {
            setNeedsDisplay()
        }
    }

    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }

        // Fill the entire view with a black color with 0.2 alpha
        context.setFillColor(UIColor.black.withAlphaComponent(0.5).cgColor)
        context.fill(rect)

        // Clear the scrollView's area to make it transparent
        context.clear(scrollViewFrame)

        // Optional: Draw a border around the scrollView area
        context.setStrokeColor(UIColor.white.cgColor)
        context.setLineWidth(1)
        context.stroke(scrollViewFrame)
    }
}
