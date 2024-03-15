import Foundation

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
