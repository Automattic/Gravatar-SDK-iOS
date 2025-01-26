import Foundation
import Vision

extension CVPixelBuffer {
    /// Finds the minimal bounding rectangle enclosing all non-zero pixels in the mask.
    /// - Returns: A CGRect representing the bounding box or nil if no foreground pixels are found.
    private func findBoundingRectInMask() -> CGRect? {
        let maskBuffer = self
        let width = CVPixelBufferGetWidth(maskBuffer)
        let height = CVPixelBufferGetHeight(maskBuffer)

        CVPixelBufferLockBaseAddress(maskBuffer, .readOnly)
        defer { CVPixelBufferUnlockBaseAddress(maskBuffer, .readOnly) }

        guard let baseAddress = CVPixelBufferGetBaseAddress(maskBuffer) else {
            print("Failed to get base address.")
            return nil
        }

        let bytesPerRow = CVPixelBufferGetBytesPerRow(maskBuffer)
        let buffer = baseAddress.assumingMemoryBound(to: UInt8.self)

        var minX = width
        var maxX = 0
        var minY = height
        var maxY = 0

        for y in 0 ..< height {
            var rowHasPixel = false
            let rowStart = y * bytesPerRow
            for x in 0 ..< width {
                let pixel = buffer[rowStart + x]
                if pixel != 0 {
                    if !rowHasPixel {
                        minY = min(minY, y)
                        maxY = max(maxY, y)
                        rowHasPixel = true
                    }
                    minX = min(minX, x)
                    maxX = max(maxX, x)
                }
            }
        }

        if minX <= maxX && minY <= maxY {
            return CGRect(x: minX, y: minY, width: maxX - minX + 1, height: maxY - minY + 1)
        }
        return nil // No foreground pixels found
    }
}
