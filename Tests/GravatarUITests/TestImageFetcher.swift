import Foundation
import Gravatar
import GravatarUI
import XCTest

public enum GravatarImageSetMockResult {
    case fail
    case success
}

public class TestImageFetcher: ImageDownloader {
    public var result: GravatarImageSetMockResult

    public init(result: GravatarImageSetMockResult) {
        self.result = result
    }

    public func fetchImage(with url: URL, forceRefresh: Bool, processingMethod: ImageProcessingMethod) async throws -> ImageDownloadResult {
        let task = Task<ImageDownloadResult, Error> {
            switch result {
            case .fail:
                let response = HTTPURLResponse(url: url, statusCode: 404, httpVersion: nil, headerFields: nil)!
                throw ImageFetchingError.responseError(reason: .invalidHTTPStatusCode(response: response))
            case .success:
                return ImageDownloadResult(image: ImageHelper.testImage, sourceURL: URL(string: url.absoluteString)!)
            }
        }
        return try await task.value
    }
}
