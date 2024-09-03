import SwiftUI
import UIKit

struct UploadFailedError: Hashable {
    let imageLocalID: String
    let reason: String
    let isRetryable: Bool
}

struct AvatarImageModel: Hashable, Identifiable, Sendable {
    enum Source: Hashable {
        case remote(url: String)
        case local(image: UIImage)
    }

    let id: String
    let isLoading: Bool
    let uploadFailedError: UploadFailedError?
    let source: Source

    var url: URL? {
        guard case .remote(let url) = source else {
            return nil
        }
        return URL(string: url)
    }

    var localImage: Image? {
        guard case .local(let image) = source else {
            return nil
        }
        return Image(uiImage: image)
    }

    var localUIImage: UIImage? {
        guard case .local(let image) = source else {
            return nil
        }
        return image
    }

    init(id: String, source: Source, isLoading: Bool = false, uploadFailedError: UploadFailedError? = nil) {
        self.id = id
        self.source = source
        self.isLoading = isLoading
        self.uploadFailedError = uploadFailedError
    }

    func settingLoading(to newLoadingStatus: Bool) -> AvatarImageModel {
        AvatarImageModel(id: id, source: source, isLoading: newLoadingStatus, uploadFailedError: uploadFailedError)
    }
}
