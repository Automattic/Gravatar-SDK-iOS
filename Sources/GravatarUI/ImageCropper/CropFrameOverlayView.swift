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

        // Clear the scrollView's area to make it transparent
        context.clear(scrollViewFrame)

        // Draw a border around the crop frame
        context.setStrokeColor(UIColor.white.cgColor)
        context.setLineWidth(1)
        context.stroke(scrollViewFrame)
    }
}
