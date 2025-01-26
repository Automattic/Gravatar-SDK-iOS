import UIKit

extension UIImage {
    /// Crops a UIImage to the specified CGRect by ensuring that the rect is within image bounds.
    /// - Parameters:
    ///   - rect: The CGRect defining the crop area.
    /// - Returns: A cropped UIImage or nil if cropping fails.
    private func safeCropImage(to rect: CGRect) -> UIImage? {
        guard let cgImage = self.cgImage else {
            print("Failed to get CGImage from UIImage.")
            return nil
        }

        // Ensure the rect is within image bounds
        let imageWidth = CGFloat(cgImage.width)
        let imageHeight = CGFloat(cgImage.height)
        let safeRect = rect.intersection(CGRect(x: 0, y: 0, width: imageWidth, height: imageHeight))

        guard let croppedCGImage = cgImage.cropping(to: safeRect) else {
            print("Failed to crop CGImage.")
            return nil
        }

        return UIImage(cgImage: croppedCGImage, scale: self.scale, orientation: self.imageOrientation)
    }

    func safeCropImage(toVisionRect rect: CGRect) -> UIImage? {
        // UIKit's Y-axis is inverted compared to Core Graphics
        let convertedY = rect.height - rect.origin.y - rect.height
        let newRect = CGRect(x: rect.origin.x, y: convertedY, width: rect.width, height: rect.height)
        return safeCropImage(to: rect)
    }
}
