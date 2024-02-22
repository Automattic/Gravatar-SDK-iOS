import UIKit

public protocol ImageUploader {
    func uploadImage(
        _ image: UIImage,
        accountEmail: String,
        accountToken: String
    ) async throws -> URLResponse

    func uploadImage(
        _ image: UIImage,
        accountEmail: String,
        accountToken: String,
        completion: ((_ error: NSError?) -> Void)?
    )
}
