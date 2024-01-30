import XCTest
@testable import Gravatar

final class ImageServiceTests: XCTestCase {
    func testFetchImage() async throws {
        let response = HTTPURLResponse.successResponse(with: URL(string: "https://gravatar.com/avatar/SOMEHASH"))
        let sessionMock = URLSessionMock(returnData: ImageHelper.testImageData, response: response)
        let service = ImageService(urlSession: sessionMock)

        let imageResponse = try await service.fetchImage(from: "some@email.com")

        XCTAssertEqual(sessionMock.request?.url?.absoluteString, "https://gravatar.com/avatar/676212ff796c79a3c06261eb10e3f455aa93998ee6e45263da13679c74b1e674")
        XCTAssertNotNil(imageResponse.image)
    }

    func testFetchImageURLResponseError() async throws {
        let response = HTTPURLResponse()
        let sessionMock = URLSessionMock(returnData: ImageHelper.testImageData, response: response)
        let service = ImageService(urlSession: sessionMock)

        do {
            _ = try await service.fetchImage(from: "")
        } catch {
            XCTAssertEqual(error.localizedDescription, (GravatarImageDownloadError.responseError(reason: .urlMismatch) as NSError).localizedDescription)
        }
    }

    func testUploadImage() async throws {

        
    }
}

extension HTTPURLResponse {
    static func successResponse(with url: URL?) -> HTTPURLResponse {
        HTTPURLResponse(url: url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
    }
}
