import CoreImage.CIFilterBuiltins
import Foundation
import SwiftUI
import Vision

extension VNDetectedObjectObservation {
    /* func boundingBoxInPixels(withSize size: CGSize) -> CGRect {
         let imageWidth: CGFloat = size.width
         let imageHeight: CGFloat = size.height
         // Convert the normalized bounding box to pixel coordinates
         let pixelX = boundingBox.origin.x * imageWidth
         let pixelY = boundingBox.origin.y * imageHeight
         let pixelWidth = boundingBox.size.width * imageWidth
         let pixelHeight = boundingBox.size.height * imageHeight

         let pixelBoundingBox = CGRect(x: pixelX, y: pixelY, width: pixelWidth, height: pixelHeight)
         return pixelBoundingBox
     }*/

    // The Vision framework’s coordinate system starts from the bottom-left,
    // but UIKit and CoreGraphics (used in drawing) use a top-left origin.
    func boundingBoxInPixelsForUIKit(withSize size: CGSize, scale: CGFloat) -> CGRect {
        let imageWidth: CGFloat = size.width
        let imageHeight: CGFloat = size.height
        // Convert the normalized bounding box to pixel coordinates
        let pixelX = boundingBox.origin.x * imageWidth
        let pixelY = boundingBox.origin.y * imageHeight
        let pixelWidth = boundingBox.size.width * imageWidth
        let pixelHeight = boundingBox.size.height * imageHeight
        let flippedY = imageHeight - pixelY - pixelHeight

        let flippedBoundingBox = CGRect(x: pixelX, y: flippedY, width: pixelWidth, height: pixelHeight)
        return flippedBoundingBox
    }
}
