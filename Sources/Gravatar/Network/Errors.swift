import Foundation
import UIKit

public enum ResponseErrorReason: Sendable {
    /// An error occurred in the system URL session.
    case URLSessionError(error: Error)

    /// The response contains an invalid HTTP status code. By default, status code >= 400 is recognized as invalid.
    case invalidHTTPStatusCode(response: HTTPURLResponse, errorPayload: APIErrorPayload? = nil)

    /// The response is not a `HTTPURLResponse`.
    case invalidURLResponse(response: URLResponse)

    /// An unexpected error has occurred.
    case unexpected(Error)

    // `true` if self is a `.invalidHTTPStatusCode`.
    public var isInvalidHTTPStatusCode: Bool {
        if case .invalidHTTPStatusCode = self {
            return true
        }
        return false
    }

    // If self is a `.invalidHTTPStatusCode` returns the HTTP statusCode from the response. Otherwise returns `nil`.
    public var httpStatusCode: Int? {
        if case .invalidHTTPStatusCode(let response, _) = self {
            return response.statusCode
        }
        return nil
    }

    public var errorPayload: APIErrorPayload? {
        if case .invalidHTTPStatusCode(_, let payload) = self {
            return payload
        }
        return nil
    }

    public var cancelled: Bool {
        if case .URLSessionError(let error) = self {
            return (error as NSError).code == -999
        }
        return false
    }

    public var isURLSessionError: Bool {
        guard case .URLSessionError(let error as NSError) = self else { return false }
        return error.domain == NSURLErrorDomain
    }

    public var urlSessionErrorLocalizedDescription: String? {
        if case .URLSessionError(let error as NSError) = self, error.domain == NSURLErrorDomain {
            return error.localizedDescription
        }
        return nil
    }
}

public enum RequestErrorReason: Sendable {
    /// The URL could not be initialized.
    case urlInitializationFailed

    /// The input url is empty or `nil`.
    case emptyURL
}

/// Errors thrown by `ImageDownloadService` when fetching an image.
public enum ImageFetchingError: Error, Sendable {
    case requestError(reason: RequestErrorReason)
    case responseError(reason: ResponseErrorReason)
    /// The `ImageProcessor` has failed and the image could not be created from the downloaded data.
    case imageProcessorFailed
}

/// Errors thrown by Gravatar compatible UI components(see: `GravatarCompatible`) when fetching an image.
public enum ImageFetchingComponentError: Error {
    case requestError(reason: RequestErrorReason)
    case responseError(reason: ResponseErrorReason)
    /// Could not initialize the image from the downloaded data.
    case imageProcessorFailed

    /// The resource task is finished, but it is not the one expected now. It's outdated because of new requests.
    /// In any case the result of this original task is contained in the associated value. So if the task succeeded the image is available in the result, if
    /// failed the error is.
    /// - result: The Result enum. `ImageDownloadResult` if the source task is finished without problem.  `Error` if an issue happens.
    /// - source: The original source value of the task.
    case outdatedTask(result: Result<ImageDownloadResult, ImageFetchingError>, source: URL)

    // `true` if self is a `.outdatedTask`.
    public var isOutdatedTask: Bool {
        if case .outdatedTask = self {
            return true
        }
        return false
    }
}

public enum ImageUploadError: Error {
    /// Conversion from UIImage to Data failed.
    case cannotConvertImageIntoData
    case responseError(reason: ResponseErrorReason)
}

public enum APIError: Error {
    case requestError(reason: RequestErrorReason)
    case responseError(reason: ResponseErrorReason)
    /// Error occurred while decoding the response.
    case decodingError(DecodingError)
}

extension APIError: CustomDebugStringConvertible {
    public var debugDescription: String {
        switch self {
        case .responseError(let reason):
            "A response error has occoured with reason: \(reason)"
        case .requestError(let reason):
            "Something went wrong when creating the request. Reason: \(reason)."
        case .decodingError(let error):
            "Something went wrong while decoding the response. Underlying error: \(error)"
        }
    }
}
