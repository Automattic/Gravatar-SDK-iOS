@testable import Gravatar
@testable import GravatarUI
import XCTest

final class ImageDownloadServiceTests: XCTestCase {
    func testFetchImageWithCompletionHandlerAndURL() {
        let imageURL = "https://gravatar.com/avatar/HASH"
        let response = HTTPURLResponse.successResponse(with: URL(string: imageURL))
        let sessionMock = URLSessionMock(returnData: ImageHelper.testImageData, response: response)
        let service = imageDownloadService(with: sessionMock)
        let expectation = expectation(description: "Request finishes")

        service.fetchImage(with: URL(string: imageURL)!) { response in
            switch response {
            case .success(let result):
                XCTAssertNotNil(result.image)
                XCTAssertEqual(result.sourceURL.absoluteString, imageURL)
            case .failure(let error):
                XCTFail(error.localizedDescription)
            }
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 0.2)
    }

    func testFetchImageWithCompletionHandlerError() throws {
        let imageURL = try XCTUnwrap(URL(string: "https://gravatar.com/avatar/HASH"))
        let response = HTTPURLResponse.errorResponse(code: 404)
        let sessionMock = URLSessionMock(returnData: ImageHelper.testImageData, response: response)
        let service = imageDownloadService(with: sessionMock)
        let expectation = expectation(description: "Request finishes")

        service.fetchImage(with: imageURL) { response in
            switch response {
            case .failure(.responseError(reason: let reason)) where reason.httpStatusCode == 404:
                break
            default:
                XCTFail("Request should fail")
            }
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 0.2)
    }
}

private func imageDownloadService(with session: URLSessionProtocol, cache: ImageCaching? = nil) -> ImageDownloadService {
    let client = URLSessionHTTPClient(urlSession: session)
    let service = ImageDownloadService(client: client, cache: cache)
    return service
}
