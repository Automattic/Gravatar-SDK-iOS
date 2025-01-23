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
        /* guard let buffer = segmentationResults?.segmentationMask else {
             return 0
         } */
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

@available(iOS 17.0, *)
struct PersonInstanceMaskResults: SegmentationResults {
    var numSegments: Int
    // var includedSegments: [Int] = []
    var segmentationMask: CVPixelBuffer
    let instanceMasks: VNInstanceMaskObservation
    let requestHandler: VNImageRequestHandler
    let faces: [VNFaceObservation]?
    let scale: CGFloat
    let orientation: UIImage.Orientation
    var type: SegmentationType { .personInstance }
    init(
        results: VNInstanceMaskObservation,
        requestHandler: VNImageRequestHandler,
        faces: [VNFaceObservation]?,
        scale: CGFloat,
        orientation: UIImage.Orientation
    ) {
        self.instanceMasks = results
        self.segmentationMask = results.instanceMask
        self.numSegments = results.allInstances.count + 1
        self.requestHandler = requestHandler
        self.faces = faces
        self.scale = scale
        self.orientation = orientation
    }

    /// The segmentation mask is an image in which each pixel’s value corresponds to the class (or segment) that pixel belongs to.
    func segmentForPixelValue(_ value: UInt8) -> Int {
        Int(value)
    }

    func generateSegmentedImage(baseImage: CIImage, selectedSegments: IndexSet) async -> UIImage? {
        do {
            let maskedResultImageBuffer = try instanceMasks.generateMaskedImage(
                ofInstances: selectedSegments,
                from: requestHandler,
                croppedToInstancesExtent: true
            )
            let maskedResultImage = CIImage(cvPixelBuffer: maskedResultImageBuffer)
            if let image = CIContext().createCGImage(maskedResultImage, from: maskedResultImage.extent) {
                return UIImage(cgImage: image, scale: scale, orientation: orientation)
            }
        } catch {
            print("Error generating mask: \(error).")
        }
        return nil
    }
}

struct PeopleSegmentationResults: SegmentationResults {
    // var includedSegments: [Int]
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
        /* let blendFilter = CIFilter.blendWithMask()
         blendFilter.inputImage = baseImage
         blendFilter.backgroundImage = CIImage(color: CIColor(color: .clear)).cropped(to: baseImage.extent)
         blendFilter.maskImage = maskImage
         let segmentedImage = blendFilter.outputImage!
         */
        return UIImage(cgImage: CIContext().createCGImage(segmentedImage, from: segmentedImage.extent)!, scale: scale, orientation: orientation)
        /* if selectedSegments.contains(1) {
             // Foreground is selected.
             segmentedImage = blendImageWithMask(image: baseImage, mask: maskImage, color: SegmentationModel.colors[1])
         }
         if selectedSegments.contains(0) {
             // Background is selected.
             let blendFilter = CIFilter.blendWithMask()
             blendFilter.inputImage = baseImage
             blendFilter.backgroundImage = CIImage(color: CIColor(color: SegmentationModel.colors[0])).cropped(to: baseImage.extent)
             blendFilter.maskImage = maskImage
             segmentedImage = blendFilter.outputImage!
         }
         return UIImage(cgImage: CIContext().createCGImage(segmentedImage, from: segmentedImage.extent)!) */
    }
}

@available(iOS 17.0, *)
struct ForegroundInstanceMaskResult: SegmentationResults {
    var numSegments: Int
    var segmentationMask: CVPixelBuffer
    let instanceMasks: VNInstanceMaskObservation
    let requestHandler: VNImageRequestHandler
    var type: SegmentationType { .foreground }

    // let faces: [VNFaceObservation]?
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
