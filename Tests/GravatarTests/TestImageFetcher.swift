import Foundation
@testable import Gravatar
import XCTest

enum GravatarImageSetMockResult {
    case fail
    case success
}

class TestImageFetcher: ImageServing {
    var result: GravatarImageSetMockResult
    var taskIdentifier: Int = 0
    var completionQueue: [(url: String, handler: Gravatar.ImageDownloadCompletion?)] = []
    
    init(result: GravatarImageSetMockResult) {
        self.result = result
    }
    
    func fetchImage(with url: URL, forceRefresh: Bool, processingMethod: ImageProcessingMethod, completionHandler: Gravatar.ImageDownloadCompletion?) -> Gravatar.CancellableDataTask? {
        completionQueue.append((url.absoluteString, completionHandler))
        taskIdentifier += 1
        return TestDataTask(taskIdentifier: taskIdentifier)
    }

    func fetchImage(with email: String, options: Gravatar.GravatarImageDownloadOptions, completionHandler: Gravatar.ImageDownloadCompletion?) -> Gravatar.CancellableDataTask {
        completionQueue.append((email, completionHandler))
        taskIdentifier += 1
        return TestDataTask(taskIdentifier: taskIdentifier)
    }

    func fetchImage(with url: URL, forceRefresh: Bool, processingMethod: ImageProcessingMethod) async throws -> Gravatar.GravatarImageDownloadResult {
        fatalError("Not Implemented")
    }

    func fetchImage(with email: String, options: Gravatar.GravatarImageDownloadOptions) async throws -> Gravatar.GravatarImageDownloadResult {
        fatalError("Not Implemented")
    }

    func sendResponse(for urlString: String) {
        switch result {
        case .fail:
            if let tuple = item(for: urlString),
                let url = URL(string: urlString),
                let response = HTTPURLResponse(url: url, statusCode: 404, httpVersion: nil, headerFields: nil) {
                tuple.1?(.failure(.responseError(reason: .invalidHTTPStatusCode(response: response))))
            }
        case .success:
            if let tuple = item(for: urlString) {
                tuple.1?(.success(GravatarImageDownloadResult(image: ImageHelper.testImage, sourceURL: URL(string: urlString)!)))
            }
        }
    }
    
    func sendNextResponse() {
        if let tuple = completionQueue.first {
            sendResponse(for: tuple.url)
            _ = completionQueue.dropFirst()
            return
        }
        XCTFail("There's no queued response to send")
    }
    
    func item(for url: String) -> (String, Gravatar.ImageDownloadCompletion?)? {
        return completionQueue.first { $0.0 == url }
    }
}

class TestDataTask: CancellableDataTask {
    init(cancelled: Bool = false, taskIdentifier: Int) {
        self.cancelled = cancelled
        self.taskIdentifier = taskIdentifier
    }
    var cancelled = false
    var taskIdentifier: Int
    
    func cancel() {
        cancelled = true
    }
}
