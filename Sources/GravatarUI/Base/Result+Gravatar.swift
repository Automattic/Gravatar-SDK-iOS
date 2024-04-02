import Foundation
import Gravatar

extension Result<ImageDownloadResult, ImageFetchingError> {
    func map() -> Result<ImageDownloadResult, ImageFetchingComponentError> {
        switch self {
        case .success(let value):
            .success(value)
        case .failure(let error):
            .failure(error.map())
        }
    }
}

extension ImageFetchingError {
    func map() -> ImageFetchingComponentError {
        switch self {
        case .requestError(let reason):
            .requestError(reason: reason)
        case .responseError(let reason):
            .responseError(reason: reason)
        case .imageProcessorFailed:
            .imageProcessorFailed
        }
    }
}

