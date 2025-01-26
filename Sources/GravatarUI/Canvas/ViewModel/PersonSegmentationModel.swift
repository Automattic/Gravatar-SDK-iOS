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

    static var defaultType: SegmentationType {
        if #available(iOS 17.0, *) {
            .foreground
        } else {
            .people
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

@MainActor
class PersonSegmentationModel: ObservableObject {
    var segmentationCount = 0
    @MainActor @Published var segmentedImageMap: [SegmentationType: UIImage] = [:]
    private let processor = SegmentationProcessor()

    func runSegmentationRequestOnImage(_ image: UIImage, for segmentationType: SegmentationType) async throws(SegmentationError) {
        let image = try await processor.runSegmentationRequestOnImage(image, for: segmentationType)
        Task { @MainActor in
            self.segmentedImageMap[segmentationType] = image
        }
    }

    func suggestedSegmentationType(for image: UIImage) async -> SegmentationType {
        await processor.suggestedSegmentationType(for: image)
    }
}

actor SegmentationProcessor {
    private var selectedSegments: IndexSet = []
    private var imageDetectionResults: [Int: DetectionResults] = [:]

    func runSegmentationRequestOnImage(_ image: UIImage, for segmentationType: SegmentationType) async throws(SegmentationError) -> UIImage {
        let baseCIImage = CIImage(image: image)
        guard let baseImage = baseCIImage else {
            throw SegmentationError.failure
        }

        var numberOfFaces = 0
        if segmentationType == .people {
            numberOfFaces = await imageDetectionResults(for: image)?.facesCount ?? 0
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
        }

        guard let segmentationResults else {
            throw SegmentationError.failure
        }

        guard let image = await segmentationResults.generateSegmentedImage(baseImage: baseImage, selectedSegments: selectedSegments) else {
            throw SegmentationError.failure
        }
        return image
    }

    struct DetectionResults: Sendable {
        let facesCount: Int
        let animalsCount: Int
    }

    private func imageDetectionResults(for image: UIImage) async -> DetectionResults? {
        guard let ciImage = CIImage(image: image) else {
            return nil
        }
        if let result = imageDetectionResults[ciImage.hash] {
            return result
        } else {
            do {
                let results = try await performFaceAndAnimalDetection(on: ciImage)
                return results
            } catch {
                return nil
            }
        }
    }

    // Analyzes the image and suggests the proper segmentation type.
    func suggestedSegmentationType(for image: UIImage) async -> SegmentationType {
        guard #available(iOS 17.0, *) else {
            return .people
        }
        do {
            guard let ciImage = CIImage(image: image) else {
                return SegmentationType.defaultType
            }
            let results = try await performFaceAndAnimalDetection(on: ciImage)
            imageDetectionResults[ciImage.hash] = results
            if results.animalsCount > 0 {
                return .foreground
            } else if results.facesCount > 2 || results.facesCount == 0 {
                return .foreground
            }
            return .people
        } catch {
            return SegmentationType.defaultType
        }
    }

    private func performFaceAndAnimalDetection(on image: CIImage) async throws -> DetectionResults {
        try await withCheckedThrowingContinuation { continuation in
            // Create face detection request
            let faceRequest = VNDetectFaceRectanglesRequest()

            // Create animal recognition request
            let animalRequest = VNRecognizeAnimalsRequest { request, error in
                if let error {
                    continuation.resume(throwing: error)
                    return
                }
                // Extract animal observations
                let animalObservations = request.results as? [VNRecognizedObjectObservation] ?? []

                // Extract face observations from the faceRequest's results
                let faceObservations = faceRequest.results ?? []

                // Resume with combined results
                let results = DetectionResults(facesCount: faceObservations.count, animalsCount: animalObservations.count)
                continuation.resume(returning: results)
            }
            // Create a request handler
            let handler = VNImageRequestHandler(ciImage: image, options: [:])
            do {
                try handler.perform([faceRequest, animalRequest])
            } catch {
                continuation.resume(throwing: error)
            }
        }
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
