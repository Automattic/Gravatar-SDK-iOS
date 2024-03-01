import Foundation

extension Result<GravatarImageDownloadResult, ImageFetchingError> {
    func map() -> Result<GravatarImageDownloadResult, ImageFetchingComponentError> {
        switch self {
        case .success(let value):
            .success(value)
        case .failure(let error):
            .failure(error.map())
        }
    }
}
