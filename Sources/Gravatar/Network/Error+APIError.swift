import Foundation
import OpenAPIRuntime

extension Error {
    func map() -> APIError {
        switch self {
        case let error as ClientError:
            if let error = error.underlyingError as? DecodingError {
                return APIError.decodingError(error)
            }
            else {
                return APIError.other(self)
            }
        default:
            return APIError.other(self)
        }
    }
}
