import SwiftUI
import PhotosUI
@preconcurrency import Vision

struct DetectedFaceModel: Sendable, Identifiable {
    let id: UUID = .init()
    let face: VNFaceObservation
    
    let boundingBox: CGRect
    let headBoundingBox: CGRect
    let confidence: VNConfidence
    let yaw: NSNumber?
    let pitch: NSNumber?
    let roll: NSNumber?
    let quality: Float?
    let landmarks: VNFaceLandmarks2D?
    
    init(face: VNFaceObservation) {
        self.quality = face.faceCaptureQuality
        self.face = face
        self.confidence = face.confidence
        self.boundingBox = face.boundingBox
        self.headBoundingBox = Self.rectForHead(face: face, headToFaceRatio: 1.75)
        self.yaw = face.yaw
        self.pitch = face.pitch
        self.roll = face.roll
        self.landmarks = face.landmarks
    }
    
    private static func rectForHead(face: VNFaceObservation, headToFaceRatio: CGFloat) -> CGRect {
        let yaw: NSNumber = face.yaw ?? 0
        let pitch: NSNumber = face.pitch ?? 0
        
        let x = face.boundingBox.minX - ((face.boundingBox.width * headToFaceRatio - face.boundingBox.width) / 2)
        let y = face.boundingBox.minY - ((face.boundingBox.height * headToFaceRatio - face.boundingBox.height) / 2) * (3 / 5)
        let width = face.boundingBox.width * headToFaceRatio
        let height = face.boundingBox.height * headToFaceRatio

        return CGRect(
            x: x,
            y: y,
            width: width,
            height: height
        )
    }
}

extension VNFaceLandmarkRegion2D? {
    func convertPointsToImageCoordinates(with imageSize: CGSize) -> [CGPoint]? {
        guard let self else { return nil }
        var points: [CGPoint] = []
        for point in self.normalizedPoints {
            points.append(
                VNImagePointForNormalizedPoint(
                    point,
                    Int(imageSize.width),
                    Int(imageSize.height)
                )
            )
        }
        return points
    }
}

struct LandmarkRegionOverlayView: View {
    let landmarks: VNFaceLandmarks2D
    let imageSize: CGSize
    let color: Color
    
    var body: some View {
        LandmarkRegionShape(
            points: landmarks.faceContour.convertPointsToImageCoordinates(with: imageSize)
        ).stroke(color, lineWidth: 2)
    }
}

struct HeadDetectionOverlayView: View {
    var geometry: GeometryProxy
    var imageSize: CGSize
    var color: Color
    @Binding var detectedFaces: [DetectedFaceModel]
    
    var body: some View {
        ForEach(detectedFaces) { (faceModel: DetectedFaceModel) in
            HeadDetectionShape(
                faceModel: faceModel,
                imageSize: imageSize,
                targetSize: geometry.size
            )?.stroke(color, lineWidth: 2)
        }
    }
}

struct FaceDetectionOverlayView: View {
    var geometry: GeometryProxy
    var imageSize: CGSize
    var color: Color
    @Binding var detectedFaces: [DetectedFaceModel]
    
    var body: some View {
        ForEach(detectedFaces) { (faceModel: DetectedFaceModel) in
            FaceRectangleShape(
                faceModel: faceModel,
                imageSize: imageSize,
                targetSize: geometry.size
            )?.stroke(color, lineWidth: 2)
        }
    }
}

struct DemoFaceDetectionView: View {
 
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var selectedImage: UIImage? = nil
    @State private var detectedFaces: [DetectedFaceModel] = []
    
    var body: some View {
        GeometryReader { geometry in
            if let image = selectedImage {
                ZStack {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    FaceDetectionOverlayView(
                        geometry: geometry,
                        imageSize: image.size,
                        color: .red,
                        detectedFaces: $detectedFaces
                    )
                    HeadDetectionOverlayView(
                        geometry: geometry,
                        imageSize: image.size,
                        color: .blue,
                        detectedFaces: $detectedFaces
                    )
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                PhotosPicker(selection: $selectedItem, matching: .images, photoLibrary: .shared()) {
                    Label("Select Image", systemImage: "photo")
                }
            }
        }
        .onChange(of: selectedItem) { _, newValue in
            Task {
                if let data = try? await newValue?.loadTransferable(type: Data.self),
                   let uiImage = UIImage(data: data) {
                    selectedImage = uiImage
                    self.detectedFaces = try await detectFaces(in: uiImage)
                }
            }
        }
        .ignoresSafeArea()
    }
    
    func detectFaces(in image: UIImage) async throws -> [DetectedFaceModel] {
        guard let cgImage = image.normalizedImage().cgImage else {
            throw FaceDetectionError.unableToConvertImageForDetection
        }
        
        // Create the face detection request
        let request = VNDetectFaceRectanglesRequest()
        
        // Create the image request handler
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        
        // Perform the request asynchronously
        return try await withCheckedThrowingContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async {
                do {
                    try handler.perform([request])
                    if let results = request.results {
                        continuation.resume(returning: results.map { DetectedFaceModel(face: $0) })
                    } else {
                        continuation.resume(throwing: FaceDetectionError.unableToDetectFaces)
                    }
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}

enum FaceDetectionError: Error, LocalizedError {
    case unableToConvertImageForDetection
    case unableToDetectFaces
    
    var errorDescription: String? {
        switch self {
        case .unableToConvertImageForDetection:
            return "Unable to convert image for detection."
        case .unableToDetectFaces:
            return "Unable to detect faces."
        }
    }
}

extension CGSize {
    func scaled(into containerSize: CGSize) -> CGSize {
        let size: CGSize
        if self.aspectRatio > containerSize.aspectRatio {
            // Image fills the width
            let width = containerSize.width
            let height = width / self.aspectRatio
            size = CGSize(width: width, height: height)
        } else {
            // Image fills the height
            let height = containerSize.height
            let width = height * self.aspectRatio
            size = CGSize(width: width, height: height)
        }
        
        print("Original size: \(self) | aspect ratio: \(self.aspectRatio)")
        print("Container size: \(containerSize) | aspect ratio: \(containerSize.aspectRatio)")
        print("Scaled size: \(size) | aspect ratio: \(size.aspectRatio)")
        return size
    }
}

struct LandmarkRegionShape: Shape {
    let points: [CGPoint]?
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        guard let points, let firstPoint = points.first else { return path }
        
        path.move(to: CGPoint(x: firstPoint.x * rect.width, y: (1 - firstPoint.y) * rect.height))
        for point in points.dropFirst() {
            path.addLine(to: CGPoint(x: point.x * rect.width, y: (1 - point.y) * rect.height))
        }
        path.closeSubpath()
        return path
    }
}

struct HeadDetectionShape: Shape {
    let head: CGRect
    
    func path(in rect: CGRect) -> Path {
        Path { path in
            print("Scaled rect in path: \(head)")
            path.addRect(head)
        }
    }
}

extension HeadDetectionShape {
    init?(
        faceModel: DetectedFaceModel,
        imageSize: CGSize,
        targetSize: CGSize
    ) {
        guard faceModel.confidence > 0.7 else { return nil }
        guard Self.isValidPose(
            yaw: faceModel.yaw,
            pitch: faceModel.pitch,
            roll: faceModel.roll
        ) else { return nil }
        self.head = Self.rect(forBoundingBox: faceModel.headBoundingBox, in: imageSize, for: targetSize)
    }
    
    private static func rect(forBoundingBox boundingBox: CGRect, in imageSize: CGSize, for targetSize: CGSize) -> CGRect {
        let scaledImageSize: CGSize = imageSize.scaled(into: targetSize)
        let xOffset: CGFloat =  (targetSize.width - scaledImageSize.width) / 2
        let yOffset: CGFloat = (targetSize.height - scaledImageSize.height) / 2
        
        let x: CGFloat = boundingBox.minX * scaledImageSize.width + xOffset
        let y: CGFloat = (1 - boundingBox.origin.y - boundingBox.height) * scaledImageSize.height + yOffset
        let width: CGFloat = boundingBox.width * CGFloat(scaledImageSize.width)
        let height: CGFloat = boundingBox.height * CGFloat(scaledImageSize.height)
        
        let rect = CGRect(
            x: x,
            y: y,
            width: width,
            height: height
        )
        print("Face rect: \(rect)")
        return rect
    }
    
    private static func isValidPose(yaw: NSNumber?, pitch: NSNumber?, roll: NSNumber?) -> Bool {
        guard let yaw else { return false }
        guard let pitch else { return false }
        guard let roll else { return false }
        
        let isYawValid = abs(Double(truncating: yaw)) <= .pi/4
        let isPitchValid = abs(Double(truncating: pitch)) <= .pi/8
        let isRollValid = abs(Double(truncating: roll)) <= .pi/8
        
        return isYawValid && isPitchValid && isRollValid
    }
}

struct FaceRectangleShape: Shape {
    let face: CGRect
    
    func path(in rect: CGRect) -> Path {
        Path { path in
            print("Scaled rect in path: \(face)")
            path.addRect(face)
        }
    }
}

extension FaceRectangleShape {
    init?(
        faceModel: DetectedFaceModel,
        imageSize: CGSize,
        targetSize: CGSize
    ) {
        guard faceModel.confidence > 0.7 else { return nil }
        guard Self.isValidPose(
            yaw: faceModel.yaw,
            pitch: faceModel.pitch,
            roll: faceModel.roll
        ) else { return nil }
        self.face = Self.rect(forBoundingBox: faceModel.boundingBox, in: imageSize, for: targetSize)
    }
    
    private static func rect(forBoundingBox boundingBox: CGRect, in imageSize: CGSize, for targetSize: CGSize) -> CGRect {
        let scaledImageSize: CGSize = imageSize.scaled(into: targetSize)
        let xOffset: CGFloat =  (targetSize.width - scaledImageSize.width) / 2
        let yOffset: CGFloat = (targetSize.height - scaledImageSize.height) / 2
        
        let x: CGFloat = boundingBox.minX * scaledImageSize.width + xOffset
        let y: CGFloat = (1 - boundingBox.origin.y - boundingBox.height) * scaledImageSize.height + yOffset
        let width: CGFloat = boundingBox.width * CGFloat(scaledImageSize.width)
        let height: CGFloat = boundingBox.height * CGFloat(scaledImageSize.height)
        
        let rect = CGRect(
            x: x,
            y: y,
            width: width,
            height: height
        )
        print("Face rect: \(rect)")
        let test = VNImageRectForNormalizedRect(boundingBox, Int(scaledImageSize.width), Int(scaledImageSize.height))
//        print("ImageRectForNormalizedRect: \(test)")
//        let testWithOffset = CGRect(
//            x: test.minX - xOffset,
//            y: test.minY - yOffset,
//            width: test.width,
//            height: test.height
//        )
//        print("ImageRectForNormalizedRect with offset: \(testWithOffset)")
//        let testImageThenScale = VNImageRectForNormalizedRect(boundingBox, Int(imageSize.width), Int(imageSize.height))
//        let testImageThenScaleScaled = testImageThenScale.scaled(into: targetSize)
        return rect
    }
    
    private static func isValidPose(yaw: NSNumber?, pitch: NSNumber?, roll: NSNumber?) -> Bool {
        guard let yaw else { return false }
        guard let pitch else { return false }
        guard let roll else { return false }
        
        let isYawValid = abs(Double(truncating: yaw)) <= .pi/4
        let isPitchValid = abs(Double(truncating: pitch)) <= .pi/8
        let isRollValid = abs(Double(truncating: roll)) <= .pi/8
        
        return isYawValid && isPitchValid && isRollValid
    }
}

extension CGSize {
    var aspectRatio: CGFloat { width / height }
}

extension UIImage {
    /// Returns an image with the correct orientation (top-left).
    func normalizedImage() -> UIImage {
        if imageOrientation == .up {
            return self
        }
        
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        draw(in: CGRect(origin: .zero, size: size))
        let normalizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return normalizedImage ?? self
    }
}

#Preview {
    NavigationView {
        DemoFaceDetectionView()
            .navigationTitle("Face Detection")
    }
}
