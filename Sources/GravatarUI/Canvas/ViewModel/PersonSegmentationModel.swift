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

struct SegmentationResultKey: Identifiable, Hashable {
    var id: String {
        "\(imageKey)-\(segmentationType)"
    }

    let imageKey: String
    let segmentationType: SegmentationType
}

@MainActor
class PersonSegmentationModel: ObservableObject {
    var segmentationCount = 0
    @MainActor @Published var segmentedImageMap: [SegmentationResultKey: SegmentationResult] = [:]
    @MainActor @Published var currentSegmentationResult: SegmentationResult?
    private let processor = SegmentationProcessor()

    @discardableResult
    func runSegmentationRequestOnImage(
        _ image: UIImage,
        for segmentationType: SegmentationType,
        cacheKey: String,
        setAsCurrent: Bool = false
    ) async throws(SegmentationError) -> SegmentationResult {
        let key = SegmentationResultKey(imageKey: cacheKey, segmentationType: segmentationType)
        if let cachedResult = segmentedImageMap[key] {
            return cachedResult
        }
        let result = try await processor.runSegmentationRequestOnImage(image, for: segmentationType, cacheKey: cacheKey)
        self.segmentedImageMap[key] = result
        if setAsCurrent {
            currentSegmentationResult = result
        }
        return result
    }

    func suggestedSegmentationType(for image: UIImage, cacheKey: String) async -> SegmentationType {
        await processor.suggestedSegmentationType(for: image, cacheKey: cacheKey)
    }
}
