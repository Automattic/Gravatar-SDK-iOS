import Foundation
import Gravatar

extension Error {
    func map() -> ImageFetchingError {
        switch self {
        case let error as ImageFetchingError:
            error
        case let error:
            ImageFetchingError.responseError(reason: .unexpected(error))
        }
    }
}
