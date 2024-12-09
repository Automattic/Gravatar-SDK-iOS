import SwiftUI
import PhotosUI
import Vision

struct DemoFaceDetectionView: View {
 
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var selectedImage: UIImage? = nil
    @State private var detectedFaces: [VNFaceObservation] = []
    
    var body: some View {
        GeometryReader { geometry in
            if let image = selectedImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .overlay {
                        ForEach(detectedFaces, id: \.self) { face in
                            FaceRectangleShape(face: face, image: image, geometry: geometry)
                                .stroke(Color.red, lineWidth: 2)
                        }
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
    
    func detectFaces(in image: UIImage) async throws -> [VNFaceObservation] {
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
                        continuation.resume(returning: results)
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

extension UIImage {
    func scaledSize(in containerSize: CGSize) -> CGSize {
        let size: CGSize
        if self.size.aspectRatio > containerSize.aspectRatio {
            // Image fills the width
            let width = containerSize.width
            let height = width / self.size.aspectRatio
            size = CGSize(width: width, height: height)
        } else {
            // Image fills the height
            let height = containerSize.height
            let width = height * self.size.aspectRatio
            size = CGSize(width: width, height: height)
        }
        
        print("Scaled size: \(size)")
        return size
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
    init (face: VNFaceObservation, image: UIImage, geometry: GeometryProxy) {
        self.face = Self.rect(for: face, in: image, in: geometry)
    }
    
    private static func rect(for face: VNFaceObservation, in image: UIImage, in geometry: GeometryProxy) -> CGRect {
        let scaledImageSize = image.scaledSize(in: geometry.size)
        let xOffset = (geometry.size.width - scaledImageSize.width) / 2
        let yOffset = (geometry.size.height - scaledImageSize.height) / 2
        
        let rect = CGRect(
            x: face.boundingBox.minX * CGFloat(scaledImageSize.width) + xOffset,
            y: (1 - face.boundingBox.origin.y - face.boundingBox.height) * CGFloat(scaledImageSize.height) + yOffset,
            width: face.boundingBox.width * CGFloat(scaledImageSize.width),
            height: face.boundingBox.height * CGFloat(scaledImageSize.height)
        )
        print("Face rect: \(rect)")
        return rect
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
