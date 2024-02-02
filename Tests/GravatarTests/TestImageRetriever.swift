import Foundation
import Gravatar
import XCTest

enum GravatarImageSetMockResult {
    case fail
    case success
}

class TestImageRetriever: GravatarImageRetrieverProtocol {
    var result: GravatarImageSetMockResult
    var taskIdentifier: Int = 0
    var completionQueue: [(url: String, handler: Gravatar.ImageDownloadCompletion?)] = []
    
    init(result: GravatarImageSetMockResult) {
        self.result = result
    }
    
    func retrieveImage(with url: URL, forceRefresh: Bool, processor: Gravatar.GravatarImageProcessor, completionHandler: Gravatar.ImageDownloadCompletion?) -> Gravatar.CancellableDataTask? {
        completionQueue.append((url.absoluteString, completionHandler))
        taskIdentifier += 1
        return TestDataTask(taskIdentifier: taskIdentifier)
    }
    
    func sendResponse(for url: String) {
        switch result {
        case .fail:
            if let tuple = item(for: url) {
                tuple.1?(.failure(.responseError(reason: .notFound)))
            }
        case .success:
            if let tuple = item(for: url) {
                tuple.1?(.success(GravatarImageDownloadResult(image: ImageHelper.testImage, sourceURL: URL(string: url)!)))
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
