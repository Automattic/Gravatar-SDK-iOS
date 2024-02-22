import UIKit

extension ImageService: ImageUploader {
    @discardableResult
    public func uploadImage(_ image: UIImage, accountEmail: String, accountToken: String) async throws -> URLResponse {
        guard let data = image.pngData() else {
            throw UploadError.cannotConvertImageIntoData
        }

        return try await uploadImage(data: data, accountEmail: accountEmail, accountToken: accountToken)
    }

    // TODO: Return internal SDK error (or remove completion handler support)
    public func uploadImage(_ image: UIImage, accountEmail: String, accountToken: String, completion: ((_ error: NSError?) -> Void)?) {
        Task {
            do {
                try await uploadImage(image, accountEmail: accountEmail, accountToken: accountToken)
                completion?(nil)
            } catch {
                completion?(error as NSError)
            }
        }
    }
}
