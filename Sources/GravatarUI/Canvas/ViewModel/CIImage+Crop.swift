import CoreImage
import UIKit
import Vision

// MARK: - Helper Functions

/// Converts VNPixelBufferObservation to a 2D array of pixel values.
/// - Parameter observation: The VNPixelBufferObservation containing the mask.
/// - Returns: A 2D array representing pixel values, where each element is 0 or 1.
func getPixelData(pixelBuffer: CVPixelBuffer) -> [[UInt8]]? {
    CVPixelBufferLockBaseAddress(pixelBuffer, .readOnly)
    defer { CVPixelBufferUnlockBaseAddress(pixelBuffer, .readOnly) }

    guard let baseAddress = CVPixelBufferGetBaseAddress(pixelBuffer) else {
        print("Failed to get base address of pixel buffer.")
        return nil
    }

    let width = CVPixelBufferGetWidth(pixelBuffer)
    let height = CVPixelBufferGetHeight(pixelBuffer)
    let bytesPerRow = CVPixelBufferGetBytesPerRow(pixelBuffer)
    let buffer = baseAddress.assumingMemoryBound(to: UInt8.self)

    var pixelData: [[UInt8]] = Array(repeating: Array(repeating: 0, count: width), count: height)

    for y in 0 ..< height {
        for x in 0 ..< width {
            let pixel = buffer[y * bytesPerRow + x]
            pixelData[y][x] = pixel > 0 ? 1 : 0 // Assuming non-zero means visible
        }
    }

    return pixelData
}

/// Finds the bounding rectangle of visible pixels.
/// - Parameter pixelData: A 2D array of pixel values (0 or 1).
/// - Returns: A CGRect representing the bounding box in normalized coordinates, or nil if no pixels are visible.
func findBoundingRect(from pixelData: [[UInt8]]) -> CGRect? {
    guard !pixelData.isEmpty, !pixelData[0].isEmpty else {
        return nil
    }

    let height = pixelData.count
    let width = pixelData[0].count

    var minX = width
    var maxX = 0
    var minY = height
    var maxY = 0

    for y in 0 ..< height {
        for x in 0 ..< width {
            if pixelData[y][x] != 0 {
                if x < minX { minX = x }
                if x > maxX { maxX = x }
                if y < minY { minY = y }
                if y > maxY { maxY = y }
            }
        }
    }

    // Check if any visible pixels were found
    if minX > maxX || minY > maxY {
        return nil // No visible pixels
    }

    // Convert to normalized coordinates
    let normalizedMinX = CGFloat(minX) / CGFloat(width)
    let normalizedMinY = CGFloat(minY) / CGFloat(height)
    let normalizedWidth = CGFloat(maxX - minX + 1) / CGFloat(width)
    let normalizedHeight = CGFloat(maxY - minY + 1) / CGFloat(height)

    return CGRect(x: normalizedMinX, y: normalizedMinY, width: normalizedWidth, height: normalizedHeight)
}

/// Converts a normalized CGRect to image pixel coordinates.
/// - Parameters:
///   - rect: The CGRect in normalized coordinates.
///   - imageSize: The CGSize of the original image.
/// - Returns: A CGRect in pixel coordinates.
func convertNormalizedRect(_ rect: CGRect, to imageSize: CGSize) -> CGRect {
    let x = rect.origin.x * imageSize.width
    // Vision's Y axis is from bottom to top, UIKit's Y axis is from top to bottom
    let y = (1 - rect.origin.y - rect.height) * imageSize.height
    let width = rect.width * imageSize.width
    let height = rect.height * imageSize.height
    return CGRect(x: x, y: y, width: width, height: height)
}

/// Crops a UIImage to the specified CGRect.
/// - Parameters:
///   - image: The original UIImage.
///   - rect: The CGRect defining the crop area in pixel coordinates.
/// - Returns: A cropped UIImage or nil if cropping fails.
func cropImage(_ image: UIImage, to rect: CGRect) -> UIImage? {
    guard let cgImage = image.cgImage else {
        print("Failed to get CGImage from UIImage.")
        return nil
    }

    guard let croppedCGImage = cgImage.cropping(to: rect) else {
        print("Failed to crop CGImage.")
        return nil
    }

    return UIImage(cgImage: croppedCGImage, scale: image.scale, orientation: image.imageOrientation)
}

// MARK: - Main Function

/// Processes a VNPixelBufferObservation to find the bounding box and crop the original image.
/// - Parameters:
///   - observation: The VNPixelBufferObservation containing the mask.
///   - originalImage: The original UIImage to be cropped.
/// - Returns: A cropped UIImage based on the bounding box of visible pixels, or the original image if no cropping is needed.
func cropImageBasedOnMask(pixelBuffer: CVPixelBuffer, originalImage: UIImage) -> UIImage? {
    return originalImage // TODO: fix

    // Step 1: Extract pixel data
    guard let pixelData = getPixelData(pixelBuffer: pixelBuffer) else {
        print("Failed to extract pixel data from observation.")
        return originalImage
    }

    // Step 2: Find bounding rectangle in normalized coordinates
    guard let normalizedRect = findBoundingRect(from: pixelData) else {
        print("No visible pixels found. Returning original image.")
        return originalImage
    }

    // Step 3: Convert normalized rect to image coordinates
    let imageSize = originalImage.size
    let cropRect = convertNormalizedRect(normalizedRect, to: imageSize)

    // Step 4: Crop the image
    guard let croppedImage = cropImage(originalImage, to: cropRect) else {
        print("Failed to crop the image. Returning original image.")
        return originalImage
    }

    return croppedImage
}
