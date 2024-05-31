@testable import Gravatar
@testable import TestHelpers
import XCTest

final class ImageDownloadServiceTests: XCTestCase {
    func testFetchImageWithURL() async throws {
        let imageURL = "https://gravatar.com/avatar/HASH"
        let response = HTTPURLResponse.successResponse(with: URL(string: imageURL)!)
        let sessionMock = URLSessionMock(returnData: ImageHelper.testImageData, response: response)
        let service = imageDownloadService(with: sessionMock)

        let imageResponse = try await service.fetchImage(with: URL(string: imageURL)!)
        let request = await sessionMock.request
        XCTAssertEqual(request?.url?.absoluteString, "https://gravatar.com/avatar/HASH")
        XCTAssertNotNil(imageResponse.image)
    }

    func testFetchCatchedImageWithURL() async throws {
        let imageURL = "https://gravatar.com/avatar/HASH"
        let response = HTTPURLResponse.successResponse(with: URL(string: imageURL)!)
        let sessionMock = URLSessionMock(returnData: ImageHelper.testImageData, response: response)
        let cache = TestImageCache()
        let service = imageDownloadService(with: sessionMock, cache: cache)

        _ = try await service.fetchImage(with: URL(string: imageURL)!)
        _ = try await service.fetchImage(with: URL(string: imageURL)!)
        let imageResponse = try await service.fetchImage(with: URL(string: imageURL)!)
        let setImageCallsCount = await cache.setImageCallsCount
        let setTaskCallCount = await cache.setTaskCallsCount
        let getImageCallsCount = await cache.getImageCallsCount
        let request = await sessionMock.request
        let callsCount = await sessionMock.callsCount
        XCTAssertEqual(setImageCallsCount, 1)
        XCTAssertEqual(setTaskCallCount, 1)
        XCTAssertEqual(getImageCallsCount, 3)
        XCTAssertEqual(callsCount, 1)
        XCTAssertEqual(request?.url?.absoluteString, "https://gravatar.com/avatar/HASH")
        XCTAssertNotNil(imageResponse.image)
    }
}

private func imageDownloadService(with session: URLSessionProtocol, cache: ImageCaching? = nil) -> ImageDownloadService {
    let client = URLSessionHTTPClient(urlSession: session)
    let service = ImageDownloadService(client: client, cache: cache)
    return service
}
