import Foundation

extension HTTPURLResponse {
    /// Whether the status code is an error of any kind (`4xx` or `5xx`)
    package var isError: Bool {
        isClientError || isServerError
    }

    /// Whether the status code is a client error code: `4xx`
    package var isClientError: Bool {
        statusCode >= 400 && statusCode < 500
    }

    /// Whether the status code is a client error code: `5xx`
    package var isServerError: Bool {
        statusCode >= 500 && statusCode < 600
    }
}
