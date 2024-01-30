import XCTest
@testable import Gravatar

final class ImageServiceTests: XCTestCase {
    func testFetchImage() async throws {
        let response = HTTPURLResponse.successResponse(with: URL(string: "https://gravatar.com/avatar/SOMEHASH"))
        let sessionMock = URLSessionMock(returnData: ImageHelper.testImageData, response: response)
        let service = ImageService(urlSession: sessionMock)

        let imageResponse = try await service.fetchImage(with: "some@email.com")

        XCTAssertEqual(sessionMock.request?.url?.absoluteString, "https://gravatar.com/avatar/676212ff796c79a3c06261eb10e3f455aa93998ee6e45263da13679c74b1e674?d=404&s=240&r=g")
        XCTAssertNotNil(imageResponse.image)
    }

    func testFetchImageURLResponseError() async throws {
        let response = HTTPURLResponse()
        let sessionMock = URLSessionMock(returnData: ImageHelper.testImageData, response: response)
        let service = ImageService(urlSession: sessionMock)

        do {
            _ = try await service.fetchImage(with: "")
        } catch let error as NSError {
            XCTAssertEqual(error.code, URLError.Code.badServerResponse.rawValue)
        }
    }

    func testUploadImage() async throws {
        let successResponse = HTTPURLResponse.successResponse(with: URL(string: "http://gravatar.com"))
        let sessionMock = URLSessionMock(returnData: "Success".data(using: .utf8)!, response: successResponse)
        let service = ImageService(urlSession: sessionMock)

        try await service.uploadImage(ImageHelper.testImage, accountEmail: "some@email.com", accountToken: "AccessToken")

        XCTAssertEqual(sessionMock.request?.url?.absoluteString, "https://api.gravatar.com/v1/upload-image")
        XCTAssertNotNil(sessionMock.request?.value(forHTTPHeaderField: "Authorization"))
        XCTAssertTrue(sessionMock.request?.value(forHTTPHeaderField: "Authorization")?.hasPrefix("Bearer ") ?? false)
        XCTAssertNotNil(sessionMock.request?.value(forHTTPHeaderField: "Content-Type"))
        XCTAssertTrue(sessionMock.request?.value(forHTTPHeaderField: "Content-Type")?.hasPrefix("multipart/form-data; boundary=Boundary") ?? false)
    }

    func testUploadImageError() async throws {
        let successResponse = HTTPURLResponse.errorResponse(with: URL(string: "http://gravatar.com"), code: 408)
        let sessionMock = URLSessionMock(returnData: "Error".data(using: .utf8)!, response: successResponse)
        let service = ImageService(urlSession: sessionMock)

        do {
            try await service.uploadImage(ImageHelper.testImage, accountEmail: "some@email.com", accountToken: "AccessToken")
            XCTFail("This should throw an error")
        } catch {
            XCTAssertEqual(error.localizedDescription, "request timed out")
        }
    }

    func testUploadImageWithCompletionHandler() {
        let successResponse = HTTPURLResponse.successResponse(with: URL(string: "http://gravatar.com"))
        let sessionMock = URLSessionMock(returnData: "Success".data(using: .utf8)!, response: successResponse)
        let service = ImageService(urlSession: sessionMock)
        let expectation = expectation(description: "Should succeed")

        service.uploadImage(ImageHelper.testImage, accountEmail: "some@email.com", accountToken: "AccessToken") { error in
            XCTAssertNil(error)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 0.1)
    }

    func testUploadImageWithCompletionHandlerError() {
        let successResponse = HTTPURLResponse.errorResponse(with: URL(string: "http://gravatar.com"), code: 415)
        let sessionMock = URLSessionMock(returnData: "Error".data(using: .utf8)!, response: successResponse)
        let service = ImageService(urlSession: sessionMock)
        let expectation = expectation(description: "Should error")

        service.uploadImage(ImageHelper.testImage, accountEmail: "some@email.com", accountToken: "AccessToken") { error in
            XCTAssertNotNil(error)
            XCTAssertEqual(error?.localizedDescription, "unsupported media type")
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 0.1)
    }
}

extension HTTPURLResponse {
    static func successResponse(with url: URL?) -> HTTPURLResponse {
        HTTPURLResponse(url: url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
    }

    static func errorResponse(with url: URL?, code: Int) -> HTTPURLResponse {
        HTTPURLResponse(url: url!, statusCode: code, httpVersion: nil, headerFields: nil)!
    }
}
