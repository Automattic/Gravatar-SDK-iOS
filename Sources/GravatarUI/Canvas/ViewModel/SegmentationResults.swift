import Accelerate
import CoreImage.CIFilterBuiltins
import CoreVideo
import Foundation
import SwiftUI
import Vision

protocol SegmentationResults {
    var segmentationMask: CVPixelBuffer { get set }
    var numSegments: Int { get set }
    func generateSegmentedImage(baseImage: CIImage, selectedSegments: IndexSet) async -> UIImage?
    func segmentForPixelValue(_ value: UInt8) -> Int
    func segmentAtLocation(_ location: CGPoint) -> Int
    var type: SegmentationType { get }
}

extension SegmentationResults {
    // Returns which segment a point within the image belongs to.
    func segmentAtLocation(_ location: CGPoint) -> Int {
        let buffer = segmentationMask
        // Lock PixelBuffer before reading.
        CVPixelBufferLockBaseAddress(buffer, CVPixelBufferLockFlags.readOnly)

        // Convert normalized point location to a buffer row and column.
        let width = CVPixelBufferGetWidth(buffer)
        let height = CVPixelBufferGetHeight(buffer)
        let bufferPoint = VNImagePointForNormalizedPoint(location, width, height)
        let row: Int = min(height, max(0, Int(bufferPoint.y)))
        let col: Int = min(width, max(0, Int(bufferPoint.x)))

        // Read the buffer pixel from memory.
        let baseAddress = CVPixelBufferGetBaseAddress(buffer)?.assumingMemoryBound(to: UInt8.self)
        let bytesPerRow = CVPixelBufferGetBytesPerRow(buffer)
        let pixelValue = baseAddress![col + bytesPerRow * row]
        let segment = segmentForPixelValue(pixelValue)
        // Unlock the buffer after reading completes.
        CVPixelBufferUnlockBaseAddress(buffer, CVPixelBufferLockFlags.readOnly)
        return segment
    }
}

struct PeopleSegmentationResults: SegmentationResults {
    var numSegments: Int
    var segmentationMask: CVPixelBuffer
    let scale: CGFloat
    let orientation: UIImage.Orientation
    var type: SegmentationType { .people }

    init(results: VNPixelBufferObservation, scale: CGFloat, orientation: UIImage.Orientation) {
        numSegments = 2
        segmentationMask = results.pixelBuffer
        self.scale = scale
        self.orientation = orientation
    }

    func segmentForPixelValue(_ value: UInt8) -> Int {
        value > 0 ? 1 : 0
    }

    func generateSegmentedImage(baseImage: CIImage, selectedSegments: IndexSet) async -> UIImage? {
        var maskImage = CIImage(cvPixelBuffer: segmentationMask)
        // Scale mask to image size.
        let scaleX = baseImage.extent.width / maskImage.extent.width
        let scaleY = baseImage.extent.height / maskImage.extent.height
        maskImage = maskImage.transformed(by: .init(scaleX: scaleX, y: scaleY))

        let segmentedImage = isolateImageWithMask(image: baseImage, mask: maskImage)
        return UIImage(cgImage: CIContext().createCGImage(segmentedImage, from: segmentedImage.extent)!, scale: scale, orientation: orientation)
    }
}

/// Removes unwanted people from background by making use of the results of `VNGenerateForegroundInstanceMaskRequest`
@available(iOS 17.0, *)
struct ForegroundPeopleSegmentation: SegmentationResults {
    var numSegments: Int
    var segmentationMask: CVPixelBuffer
    let scale: CGFloat
    let orientation: UIImage.Orientation
    var type: SegmentationType { .people }
    let foregroundObservation: VNInstanceMaskObservation

    init(results: VNPixelBufferObservation, scale: CGFloat, orientation: UIImage.Orientation, foregroundObservation: VNInstanceMaskObservation) {
        numSegments = 2
        segmentationMask = results.pixelBuffer
        self.scale = scale
        self.orientation = orientation
        self.foregroundObservation = foregroundObservation
    }

    func segmentForPixelValue(_ value: UInt8) -> Int {
        value > 0 ? 1 : 0
    }

    func generateSegmentedImage(baseImage: CIImage, selectedSegments: IndexSet) async -> UIImage? {
        let personMaskWidth = CVPixelBufferGetWidth(segmentationMask)
        let personMaskHeight = CVPixelBufferGetHeight(segmentationMask)

        if let scaledForegroundMask = resizeMask(
            foregroundObservation.instanceMask,
            toWidth: personMaskWidth,
            height: personMaskHeight
        ) {
            Self.removeBackgroundPixels(peopleMask: segmentationMask, foregroundMask: scaledForegroundMask)
        }

        var maskImage = CIImage(cvPixelBuffer: segmentationMask)
        // Scale mask to image size.
        let scaleX = baseImage.extent.width / maskImage.extent.width
        let scaleY = baseImage.extent.height / maskImage.extent.height
        maskImage = maskImage.transformed(by: .init(scaleX: scaleX, y: scaleY))

        let segmentedImage = isolateImageWithMask(image: baseImage, mask: maskImage)

        return UIImage(cgImage: CIContext().createCGImage(segmentedImage, from: segmentedImage.extent)!, scale: scale, orientation: orientation)
    }

    static func removeBackgroundPixels(
        peopleMask: CVPixelBuffer, // from VNGeneratePersonSegmentationRequest
        foregroundMask: CVPixelBuffer // from VNGenerateForegroundInstanceMaskRequest
    ) {
        CVPixelBufferLockBaseAddress(peopleMask, [])
        CVPixelBufferLockBaseAddress(foregroundMask, .readOnly)
        defer {
            CVPixelBufferUnlockBaseAddress(peopleMask, [])
            CVPixelBufferUnlockBaseAddress(foregroundMask, .readOnly)
        }
        let width = CVPixelBufferGetWidth(peopleMask)
        let height = CVPixelBufferGetHeight(peopleMask)

        let width2 = CVPixelBufferGetWidth(foregroundMask)
        let height2 = CVPixelBufferGetHeight(foregroundMask)

        guard width == width2, height == height2 else {
            // out of bounds risk
            return
        }

        guard let peopleBase = CVPixelBufferGetBaseAddress(peopleMask)?.assumingMemoryBound(to: UInt8.self),
              let foregroundBase = CVPixelBufferGetBaseAddress(foregroundMask)?.assumingMemoryBound(to: UInt8.self)
        else {
            return
        }

        let peopleBytesPerRow = CVPixelBufferGetBytesPerRow(peopleMask)
        let foregroundBytesPerRow = CVPixelBufferGetBytesPerRow(foregroundMask)

        for row in 0 ..< height {
            let peopleRowStart = row * peopleBytesPerRow
            let foregroundRowStart = row * foregroundBytesPerRow
            for col in 0 ..< width {
                let instanceVal = foregroundBase[foregroundRowStart + col]
                // If this pixel belongs to "background" in the foregroundMask,
                // force background in the peopleMask as well.
                if instanceVal == 0 {
                    peopleBase[peopleRowStart + col] = 0
                }
            }
        }
    }

    /// VNGenerateForegroundInstanceMaskRequest typically returns a 512×512 mask (VNInstanceMaskObservation),
    /// whereas VNGeneratePersonSegmentationRequest produces a mask matching or proportionally scaling the input image.
    /// To merge or combine masks, we need them both at the same resolution.
    func resizeMask(
        _ srcBuffer: CVPixelBuffer,
        toWidth dstWidth: Int,
        height dstHeight: Int
    ) -> CVPixelBuffer? {
        // 1) Verify pixel format is 8-bit one-channel
        let srcFmt = CVPixelBufferGetPixelFormatType(srcBuffer)
        guard srcFmt == kCVPixelFormatType_OneComponent8 else { return nil }

        // 2) Create destination CVPixelBuffer
        var dstBuffer: CVPixelBuffer?
        let status = CVPixelBufferCreate(
            nil,
            dstWidth,
            dstHeight,
            kCVPixelFormatType_OneComponent8,
            nil,
            &dstBuffer
        )
        guard status == kCVReturnSuccess, let dstBufferUnwrapped = dstBuffer else {
            return nil
        }

        // Lock both
        CVPixelBufferLockBaseAddress(srcBuffer, .readOnly)
        CVPixelBufferLockBaseAddress(dstBufferUnwrapped, [])
        defer {
            CVPixelBufferUnlockBaseAddress(srcBuffer, .readOnly)
            CVPixelBufferUnlockBaseAddress(dstBufferUnwrapped, [])
        }

        // vImage setup
        var srcVImage = vImage_Buffer(
            data: CVPixelBufferGetBaseAddress(srcBuffer)!,
            height: vImagePixelCount(CVPixelBufferGetHeight(srcBuffer)),
            width: vImagePixelCount(CVPixelBufferGetWidth(srcBuffer)),
            rowBytes: CVPixelBufferGetBytesPerRow(srcBuffer)
        )

        var dstVImage = vImage_Buffer(
            data: CVPixelBufferGetBaseAddress(dstBufferUnwrapped)!,
            height: vImagePixelCount(dstHeight),
            width: vImagePixelCount(dstWidth),
            rowBytes: CVPixelBufferGetBytesPerRow(dstBufferUnwrapped)
        )

        // 3) Scale
        let scaleError = vImageScale_Planar8(
            &srcVImage,
            &dstVImage,
            nil,
            vImage_Flags(kvImageHighQualityResampling)
        )
        guard scaleError == kvImageNoError else {
            return nil
        }

        return dstBufferUnwrapped
    }
}

@available(iOS 17.0, *)
struct ForegroundInstanceMaskResult: SegmentationResults {
    var numSegments: Int
    var segmentationMask: CVPixelBuffer
    let instanceMasks: VNInstanceMaskObservation
    let requestHandler: VNImageRequestHandler
    var type: SegmentationType { .foreground }

    let scale: CGFloat
    let orientation: UIImage.Orientation
    init(results: VNInstanceMaskObservation, requestHandler: VNImageRequestHandler, scale: CGFloat, orientation: UIImage.Orientation) {
        self.instanceMasks = results
        self.segmentationMask = results.instanceMask
        self.numSegments = results.allInstances.count + 1
        self.requestHandler = requestHandler
        self.scale = scale
        self.orientation = orientation
    }

    func generateSegmentedImage(baseImage: CIImage, selectedSegments: IndexSet) async -> UIImage? {
        do {
            let maskedResultImageBuffer = try instanceMasks.generateMaskedImage(
                ofInstances: instanceMasks.allInstances,
                from: requestHandler,
                croppedToInstancesExtent: false
            )
            let maskedResultImage = CIImage(cvPixelBuffer: maskedResultImageBuffer)
            if let cgImage = CIContext().createCGImage(maskedResultImage, from: maskedResultImage.extent) {
                let outputImage = UIImage(cgImage: cgImage, scale: scale, orientation: orientation)
                return outputImage
            }
        } catch {
            print("Error generating mask: \(error).")
        }
        return nil
    }

    func segmentForPixelValue(_ value: UInt8) -> Int {
        Int(value)
    }
}
