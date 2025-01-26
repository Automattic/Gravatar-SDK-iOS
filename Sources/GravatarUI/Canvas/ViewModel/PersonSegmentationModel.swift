import CoreImage.CIFilterBuiltins
import CoreVideo
import Foundation
import SwiftUI
import Vision

enum SegmentationType: Int, Sendable {
    /// Separates the foreground person/people/object from the background
    case foreground
    /// Separates people as a whole from the background.
    case people
    /// Separates each person instance from background up to 4 people. Not as good quality as `.people` though.
    //  case personInstance

    static var supportedTypes: [SegmentationType] {
        if #available(iOS 17.0, *) {
            [.foreground, .people /* , .personInstance */ ]
        } else {
            [.people]
        }
    }
}

enum SegmentationError: Error {
    case noFaceDetected
    case unsupportedRequest
    case failure

    var localizedMessage: String {
        switch self {
        case .noFaceDetected:
            SDKLocalizedString(
                "No human face detected. This option only works with images containing a human face.",
                comment: "Error message for removing the background of an image"
            )
        case .unsupportedRequest:
            SDKLocalizedString("The requested operation is not supported.", comment: "Error message for removing the background of an image")
        case .failure:
            SDKLocalizedString("Failed to perform segmentation.", comment: "Error message for removing the background of an image")
        }
    }
}

actor PersonSegmentationModel: ObservableObject {
    var selectedSegments: IndexSet = []
    var segmentationCount = 0
    var segmentationResults: SegmentationResults?
    var baseUIImage: UIImage?
    var baseCIImage: CIImage?
    @MainActor @Published var segmentedImageMap: [SegmentationType: UIImage] = [:]
    @MainActor @Published var segmentationType: SegmentationType = .foreground

    func runSegmentationRequestOnImage(_ image: UIImage, for segmentationType: SegmentationType) async throws(SegmentationError) {
        self.baseUIImage = image
        self.baseCIImage = CIImage(image: image)
        guard let baseImage = baseCIImage else {
            throw SegmentationError.failure
        }

        var numberOfFaces = 0
        if segmentationType != .foreground {
            numberOfFaces = await countFaces(image: baseImage)
            print("numberOfFaces: \(numberOfFaces)")
        }

        var foregroundInstanceMaskRequest: VNImageBasedRequest?
        var personSegmentationRequest: VNGeneratePersonSegmentationRequest?

        switch segmentationType {
        case .foreground:
            if #available(iOS 17.0, *) {
                foregroundInstanceMaskRequest = VNGenerateForegroundInstanceMaskRequest()
            } else {
                throw SegmentationError.unsupportedRequest
            }
        case .people:
            guard numberOfFaces > 0 else {
                throw SegmentationError.noFaceDetected
            }
            personSegmentationRequest = VNGeneratePersonSegmentationRequest()
            personSegmentationRequest?.qualityLevel = .accurate
            personSegmentationRequest?.outputPixelFormat = kCVPixelFormatType_OneComponent8
            if #available(iOS 17.0, *) {
                foregroundInstanceMaskRequest = VNGenerateForegroundInstanceMaskRequest()
            }
            /* case .personInstance:
             if #available(iOS 17.0, *) {
                 guard numberOfFaces > 0 else {
                     throw SegmentationError.noFaceDetected
                 }
                 let personInstanceMaskRequest = VNGeneratePersonInstanceMaskRequest()
                 request = personInstanceMaskRequest
             } else {
                 throw SegmentationError.unsupportedRequest
             }*/
        }

        let requestHandler = VNImageRequestHandler(ciImage: baseImage)

        do {
            try requestHandler.perform([foregroundInstanceMaskRequest, personSegmentationRequest].compactMap { $0 })
        } catch {
            print("Unable to perform the request: \(error).")
            throw SegmentationError.failure
        }

        var segmentationResults: SegmentationResults?

        switch segmentationType {
        case .foreground:
            if #available(iOS 17.0, *) {
                guard let maskObservation = foregroundInstanceMaskRequest?.results?.first as? VNInstanceMaskObservation else {
                    throw .failure
                }
                segmentationResults = ForegroundInstanceMaskResult(
                    results: maskObservation,
                    requestHandler: requestHandler,
                    scale: image.scale,
                    orientation: image.imageOrientation
                )
                selectedSegments = [1]
            } else {
                throw .unsupportedRequest
            }
        case .people:
            if #available(iOS 17.0, *) {
                guard let foregroundObservation = foregroundInstanceMaskRequest?.results?.first as? VNInstanceMaskObservation,
                      let buffer = personSegmentationRequest?.results?.first as? VNPixelBufferObservation
                else {
                    throw .failure
                }
                segmentationResults = ForegroundPeopleSegmentation(
                    results: buffer,
                    scale: image.scale,
                    orientation: image.imageOrientation,
                    foregroundObservation: foregroundObservation
                )
                selectedSegments = [1]
            } else {
                guard let buffer = personSegmentationRequest?.results?.first as? VNPixelBufferObservation else {
                    throw .failure
                }
                selectedSegments = [1]

                segmentationResults = PeopleSegmentationResults(results: buffer, scale: image.scale, orientation: image.imageOrientation)
            }
            /* case .personInstance:
             if #available(iOS 17.0, *) {
                 guard let maskObservation = request.results?.first as? VNInstanceMaskObservation else {
                     throw .failure
                 }
                 let results = PersonInstanceMaskResults(
                     results: maskObservation,
                     requestHandler: requestHandler,
                     faces: self.faces,
                     scale: image.scale,
                     orientation: image.imageOrientation
                 )
                 selectedSegments = /* guessBestSegmentsToInclude(
                     segmentationResults: results,
                     imageSize: baseImage.extent.size
                 ) ?? */ maskObservation.allInstances
                 segmentationResults = results
             } else {
                 throw .unsupportedRequest
             }*/
        }

        guard let segmentationResults else {
            throw SegmentationError.failure
        }

        guard let image = await segmentationResults.generateSegmentedImage(baseImage: baseImage, selectedSegments: selectedSegments),
              let cgImage = image.cgImage
        else {
            throw SegmentationError.failure
        }
        Task { @MainActor in
            // Sending CGImage to avoid the
            self.segmentedImageMap[segmentationResults.type] = image
        }

        /* if #available(iOS 17.0, *) {
         // Allows us to select/deselect each person one by one.
         let personInstanceMaskRequest = VNGeneratePersonInstanceMaskRequest()
         request = personInstanceMaskRequest
         } else {
         // Fallback on earlier versions. All humans are included in the picture.
         let PeopleSegmentationResults = VNGeneratePersonSegmentationRequest()
         PeopleSegmentationResults.qualityLevel = .accurate
         PeopleSegmentationResults.outputPixelFormat = kCVPixelFormatType_OneComponent8
         request = PeopleSegmentationResults

         if #available(iOS 17.0, *) {
         let foregroundInstanceRequest = VNGenerateForegroundInstanceMaskRequest()

         let anotherRequestHandler = VNImageRequestHandler(ciImage: baseImage)
         try anotherRequestHandler.perform([foregroundInstanceRequest])
         if let result = foregroundInstanceRequest.results?.first as? VNInstanceMaskObservation {

         let maskedResultImageBuffer = try result.generateMaskedImage(ofInstances: result.allInstances, from: anotherRequestHandler, croppedToInstancesExtent: false)
         let maskedResultImage = CIImage(cvPixelBuffer: maskedResultImageBuffer)
         if let cgImage = CIContext().createCGImage(maskedResultImage, from: maskedResultImage.extent) {
         let outputImage = UIImage(cgImage: cgImage, scale: image.scale, orientation: image.imageOrientation)
         Task { @MainActor in
         // Sending CGImage to avoid the
         self.segmentedImage = outputImage

         }
         }

         }
         return
         } else {
         // Fallback on earlier versions
         }
         // }

         // Set up and run the request.
         let requestHandler = VNImageRequestHandler(ciImage: baseImage)

         do {
         try requestHandler.perform([request])
         if #available(iOS 17.0, *) {
         guard let instanceMask = request.results?.first as? VNInstanceMaskObservation else {
         throw SegmentationError.noFaceDetected
         }
         let results = PersonInstanceMaskResults(results: instanceMask, requestHandler: requestHandler, faces: faces, scale: image.scale, orientation: image.imageOrientation)
         selectedSegments = guessBestSegmentsToInclude(
         segmentationResults: results,
         imageSize: baseImage.extent.size
         ) ?? instanceMask.allInstances
         segmentationResults = results
         } else {
         guard let buffer = request.results?.first as? VNPixelBufferObservation else {
         throw SegmentationError.failure
         }
         selectedSegments = [1]
         segmentationResults = PeopleSegmentationResults(results: buffer, scale: image.scale, orientation: image.imageOrientation)
         // }
         guard let segmentationResults else {
         throw SegmentationError.failure
         }
         self.segmentationCount = segmentationResults.numSegments
         guard let image = await segmentationResults.generateSegmentedImage(baseImage: baseImage, selectedSegments: selectedSegments),
         let cgImage = image.cgImage else {
         throw SegmentationError.failure
         }
         Task { @MainActor in
         // Sending CGImage to avoid the
         self.segmentedImage = UIImage(cgImage: cgImage, scale: image.scale, orientation: image.imageOrientation)

         }
         } catch {
         print("Unable to perform the request: \(error).")
         throw SegmentationError.failure
         }*/
    }

    private var faces: [VNFaceObservation]?

    // Returns the number of human faces in the image.
    private func countFaces(image: CIImage) async -> Int {
        let request = VNDetectFaceRectanglesRequest()
        let requestHandler = VNImageRequestHandler(ciImage: image)
        do {
            try requestHandler.perform([request])
            faces = request.results
            if let results = request.results {
                return results.count
            }
        } catch {
            print("Unable to perform face detection: \(error).")
        }
        return 0
    }

    /// Include the instances with face
    func guessBestSegmentsToInclude(segmentationResults: SegmentationResults, imageSize: CGSize) -> IndexSet? {
        guard let faces else { return nil }
        for face in faces {
            print("confidence: \(face.confidence)")
        }
        // include high quality faces
        let filteredFaces = faces.filter { $0.confidence > 0.7 }
        let maps = mapFacesToInstances(faces: filteredFaces, mask: segmentationResults.segmentationMask)

        let faceIndexes: [Int] = maps.map { faceMap in
            if let index = faceMap.instanceIndex {
                return Int(index)
            }
            return nil
        }.compactMap { $0 }
        return IndexSet(faceIndexes)
    }

    func mapFacesToInstances(
        faces: [VNFaceObservation],
        mask: CVPixelBuffer
    ) -> [FaceToInstanceResult] {
        faces.map { face in
            // Dictionary: instanceIndex -> overlapPixelCount
            let overlapCounts = countInstanceOverlapPixels(faceObservation: face, maskPixelBuffer: mask)

            // If every pixel is 0 (background), dictionary might be empty
            if overlapCounts.isEmpty {
                return FaceToInstanceResult(face: face, instanceIndex: nil, overlapCount: 0)
            } else {
                // Pick the instance ID with the greatest overlap
                let (bestID, bestCount) = overlapCounts.max(by: { $0.value < $1.value })!
                return FaceToInstanceResult(face: face, instanceIndex: bestID, overlapCount: bestCount)
            }
        }
    }

    func countInstanceOverlapPixels(
        faceObservation: VNFaceObservation,
        maskPixelBuffer: CVPixelBuffer
    ) -> [UInt8: Int] {
        CVPixelBufferLockBaseAddress(maskPixelBuffer, .readOnly)
        defer {
            CVPixelBufferUnlockBaseAddress(maskPixelBuffer, .readOnly)
        }

        let width = CVPixelBufferGetWidth(maskPixelBuffer)
        let height = CVPixelBufferGetHeight(maskPixelBuffer)
        guard let baseAddr = CVPixelBufferGetBaseAddress(maskPixelBuffer)?.assumingMemoryBound(to: UInt8.self)
        else {
            return [:]
        }
        let bytesPerRow = CVPixelBufferGetBytesPerRow(maskPixelBuffer)

        // Vision bounding box: (x, y, w, h) in normalized [0..1], origin is bottom-left
        let faceBox = faceObservation.boundingBox

        // Convert to pixel coords (flip Y).
        let minX = Int(round(faceBox.minX * CGFloat(width)))
        let faceHeightPx = Int(round(faceBox.height * CGFloat(height)))
        let flippedMinY = Int(round((1.0 - faceBox.maxY) * CGFloat(height)))

        let maxX = minX + Int(round(faceBox.width * CGFloat(width)))
        let maxY = flippedMinY + faceHeightPx

        // Clamp
        let clampedMinX = max(0, min(width, minX))
        let clampedMaxX = max(0, min(width, maxX))
        let clampedMinY = max(0, min(height, flippedMinY))
        let clampedMaxY = max(0, min(height, maxY))

        var resultDict = [UInt8: Int]()

        for row in clampedMinY ..< clampedMaxY {
            let rowStart = row * bytesPerRow
            for col in clampedMinX ..< clampedMaxX {
                let pixelVal = baseAddr[rowStart + col]

                // pixelVal == 0 -> background
                // pixelVal == 1 -> first person
                // pixelVal == 2 -> second person, etc.
                if pixelVal != 0 {
                    resultDict[pixelVal, default: 0] += 1
                }
            }
        }
        return resultDict
    }
}

struct FaceToInstanceResult {
    let face: VNFaceObservation
    let instanceIndex: UInt8?
    let overlapCount: Int
}

extension CGRect {
    private var area: Double {
        width * height
    }
}

struct SendableData: @unchecked Sendable {
    let data: Data
    init(data: Data) {
        self.data = data
    }
}

func isolateImageWithMask(image: CIImage, mask: CIImage) -> CIImage {
    let blendFilter = CIFilter.blendWithRedMask()
    blendFilter.inputImage = image
    blendFilter.backgroundImage = CIImage.empty() // createClearCIImage(sameSizeAs: mask)
    blendFilter.maskImage = mask
    return blendFilter.outputImage!
}

func createClearCIImage(sameSizeAs image: CIImage) -> CIImage? {
    // Get the extent (size and origin) of the input image
    let imageExtent = image.extent

    // Create a Core Graphics context with the same size as the input image
    let colorSpace = CGColorSpaceCreateDeviceRGB()
    let bitmapInfo = CGBitmapInfo.byteOrder32Little.rawValue | CGImageAlphaInfo.premultipliedFirst.rawValue
    guard let context = CGContext(
        data: nil,
        width: Int(imageExtent.width),
        height: Int(imageExtent.height),
        bitsPerComponent: 8,
        bytesPerRow: 0,
        space: colorSpace,
        bitmapInfo: bitmapInfo
    ) else {
        return nil
    }

    // Clear the context to make it transparent
    context.clear(CGRect(origin: .zero, size: imageExtent.size))

    // Create a CGImage from the context
    guard let clearCGImage = context.makeImage() else {
        return nil
    }

    // Convert the CGImage into a CIImage
    return CIImage(cgImage: clearCGImage)
}
