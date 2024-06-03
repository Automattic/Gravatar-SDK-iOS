import Foundation
import Gravatar

enum TestDataTaskFailReason: Equatable {
    case dataEmpty
    case urlSessionError
    case notFound
    case urlMismatch
}

final class TestURLSession: URLSessionProtocol {
    func upload(for request: URLRequest, from bodyData: Data) async throws -> (Data, URLResponse) {
        fatalError()
    }

    func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        fatalError()
    }

    let failReason: TestDataTaskFailReason?
    static let error = NSError(domain: "test", code: 1234)

    init(failReason: TestDataTaskFailReason? = nil) {
        self.failReason = failReason
    }

    func dataTask(with request: URLRequest, completionHandler: @escaping @Sendable (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        guard let url = request.url else {
            return URLSession.shared.dataTask(with: request)
        }
        guard let failReason else {
            let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)
            completionHandler(ImageHelper.testImageData, response, nil)
            return URLSession.shared.dataTask(with: request)
        }
        switch failReason {
        case .dataEmpty:
            let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)
            completionHandler(nil, response, nil)
            return URLSession.shared.dataTask(with: request)
        case .notFound:
            let response = HTTPURLResponse(url: url, statusCode: 404, httpVersion: nil, headerFields: nil)
            completionHandler(nil, response, nil)
            return URLSession.shared.dataTask(with: request)
        case .urlMismatch:
            let response = HTTPURLResponse(url: URL(string: "https://test.com")!, statusCode: 200, httpVersion: nil, headerFields: nil)
            completionHandler(ImageHelper.testImageData, response, nil)
            return URLSession.shared.dataTask(with: request)
        case .urlSessionError:
            completionHandler(nil, nil, TestURLSession.error)
            return URLSession.shared.dataTask(with: request)
        }
    }
}

extension ImageFetchingError: Equatable {
    public static func == (lhs: ImageFetchingError, rhs: ImageFetchingError) -> Bool {
        switch (lhs, rhs) {
        case (.requestError(let reason1), .requestError(let reason2)):
            reason1 == reason2
        case (.responseError(let reason1), .responseError(let reason2)):
            reason1 == reason2
        case (.imageProcessorFailed, .imageProcessorFailed):
            true
        default:
            false
        }
    }
}

extension ResponseErrorReason: Equatable {
    public static func == (lhs: ResponseErrorReason, rhs: ResponseErrorReason) -> Bool {
        switch (lhs, rhs) {
        case (.invalidHTTPStatusCode(let response1), .invalidHTTPStatusCode(let response2)):
            response1.statusCode == response2.statusCode
        case (.URLSessionError, .URLSessionError):
            true
        case (.unexpected, .unexpected):
            true
        case (.invalidURLResponse, .invalidURLResponse):
            true
        default:
            false
        }
    }
}

extension ImageUploadError: Equatable {
    public static func == (lhs: ImageUploadError, rhs: ImageUploadError) -> Bool {
        switch (lhs, rhs) {
        case (.responseError(let reason1), .responseError(let reason2)):
            reason1 == reason2
        case (.cannotConvertImageIntoData, .cannotConvertImageIntoData):
            true
        default:
            false
        }
    }
}
