import UIKit

public enum ImageFormat {
    case jpeg
    case png
}

extension UIImage {
    /// Saves image into the temp directory as a jpeg file.
    /// - Returns: The URL of the file.
    public func saveToFile(format: ImageFormat = .jpeg) throws -> URL? {
        func fileName(format: ImageFormat) -> String {
            switch format {
            case .jpeg:
                "image.jpg"
            case .png:
                "image.png"
            }
        }

        guard let imageData = data(for: format) else { return nil }
        let fileURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(fileName(format: format))
        try imageData.write(to: fileURL)
        return fileURL
    }

    private func data(for format: ImageFormat) -> Data? {
        switch format {
        case .jpeg:
            jpegData(compressionQuality: 1)
        case .png:
            pngData()
        }
    }
}
