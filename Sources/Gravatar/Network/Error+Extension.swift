import Foundation

extension Error {
    func apiError() -> APIError {
        switch self {
        case let error as HTTPClientError:
            APIError.responseError(reason: error.map())
        case let error as DecodingError:
            APIError.decodingError(error)
        case let error:
            APIError.responseError(reason: .unexpected(error))
        }
    }
}
