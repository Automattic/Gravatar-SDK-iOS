import Foundation

/// Some HTTP status codes we handle
package enum HTTPStatus: Int {
    case badRequest = 400
    case notFound = 404
    case unauthorized = 401
    case payloadTooLarge = 413
}
