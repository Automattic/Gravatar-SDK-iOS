import UIKit

extension ImageService: ImageUploader {
    @discardableResult
    public func uploadImage(_ image: UIImage, accountEmail: String, accountToken: String) async throws -> URLResponse {
        guard let data = image.pngData() else {
            throw ImageUploadError.cannotConvertImageIntoData
        }

        return try await uploadImage(data: data, accountEmail: accountEmail, accountToken: accountToken)
    }

    public func uploadImage(_ image: UIImage, accountEmail: String, accountToken: String, completion: ((_ error: ImageUploadError?) -> Void)?) {
        Task {
            do {
                try await uploadImage(image, accountEmail: accountEmail, accountToken: accountToken)
                completion?(nil)
            } catch let error as ImageUploadError {
                completion?(error)
            } catch {
                completion?(ImageUploadError.responseError(reason: .unexpected(error)))
            }
        }
    }
}
