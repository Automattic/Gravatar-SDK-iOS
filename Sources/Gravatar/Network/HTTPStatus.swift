import Foundation

/// Some HTTP status codes we handle
package enum HTTPStatus: Int {
    case badRequest = 400
    case unauthorized = 401
    case forbidden = 403
    case notFound = 404
    case payloadTooLarge = 413
}
