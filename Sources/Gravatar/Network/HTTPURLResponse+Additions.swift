import Foundation

extension HTTPURLResponse {
    package func hasStatus(_ status: HTTPStatus) -> Bool {
        HTTPStatus(rawValue: statusCode) == status
    }

    /// Whether the status code is an error of any kind (`4xx` or `5xx`)
    package var isError: Bool {
        is4xxError || is5xxError
    }

    /// Whether a status code is a `Client Error` status code (`4xx`)
    package var is4xxError: Bool {
        guard let status = HTTPStatus(rawValue: self.statusCode) else { return false }
        return status.is4xxError
    }

    /// Whether a status code is a `Server Error` status code (`5xx`)
    package var is5xxError: Bool {
        guard let status = HTTPStatus(rawValue: self.statusCode) else { return false }
        return status.is5xxError
    }
}

extension Int? {
    package func isStatus(_ status: HTTPStatus) -> Bool {
        guard let self else { return false }
        return status.rawValue == self
    }
}
