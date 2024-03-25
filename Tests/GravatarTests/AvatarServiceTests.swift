@testable import Gravatar
import XCTest

final class AvatarServiceTests: XCTestCase {
    enum TestData {
        static let email = "some@email.com"
        static let urlFromEmail = URL(string: "https://gravatar.com/avatar/676212ff796c79a3c06261eb10e3f455aa93998ee6e45263da13679c74b1e674")!
    }

    func testFetchImage() async throws {
        let response = HTTPURLResponse.successResponse(with: TestData.urlFromEmail)
        let sessionMock = URLSessionMock(returnData: ImageHelper.testImageData, response: response)
        let service = avatarService(with: sessionMock)
        let options = ImageDownloadOptions()

        let imageResponse = try await service.fetch(with: .email(TestData.email), options: options)

        XCTAssertEqual(sessionMock.request?.url, TestData.urlFromEmail)
        XCTAssertNotNil(imageResponse.image)
    }

    func testUploadImage() async throws {
        let successResponse = HTTPURLResponse.successResponse()
        let sessionMock = URLSessionMock(returnData: "Success".data(using: .utf8)!, response: successResponse)
        let service = avatarService(with: sessionMock)

        try await service.upload(ImageHelper.testImage, email: Email("some@email.com"), accessToken: "AccessToken")

        XCTAssertEqual(sessionMock.request?.url?.absoluteString, "https://api.gravatar.com/v1/upload-image")
        XCTAssertNotNil(sessionMock.request?.value(forHTTPHeaderField: "Authorization"))
        XCTAssertTrue(sessionMock.request?.value(forHTTPHeaderField: "Authorization")?.hasPrefix("Bearer ") ?? false)
        XCTAssertNotNil(sessionMock.request?.value(forHTTPHeaderField: "Content-Type"))
        XCTAssertTrue(sessionMock.request?.value(forHTTPHeaderField: "Content-Type")?.hasPrefix("multipart/form-data; boundary=Boundary") ?? false)
    }

    func testUploadImageError() async throws {
        let responseCode = 408
        let successResponse = HTTPURLResponse.errorResponse(code: responseCode)
        let sessionMock = URLSessionMock(returnData: "Error".data(using: .utf8)!, response: successResponse)
        let service = avatarService(with: sessionMock)

        do {
            try await service.upload(ImageHelper.testImage, email: Email("some@email.com"), accessToken: "AccessToken")
            XCTFail("This should throw an error")
        } catch ImageUploadError.responseError(reason: let reason) where reason.httpStatusCode == responseCode {
            // Expected error has ocurred.
        } catch {
            XCTFail("This should have thrown an invalidHTTPStatusCode with:\(responseCode)")
        }
    }

    func testUploadImageDataError() async throws {
        let successResponse = HTTPURLResponse.errorResponse(code: 408)
        let sessionMock = URLSessionMock(returnData: "Error".data(using: .utf8)!, response: successResponse)
        let service = avatarService(with: sessionMock)

        do {
            try await service.upload(UIImage(), email: Email("some@email.com"), accessToken: "AccessToken")
            XCTFail("This should throw an error")
        } catch let error as ImageUploadError {
            XCTAssertEqual(error, ImageUploadError.cannotConvertImageIntoData)
        }
    }

    func testForceRefreshEnabled() async throws {
        let cache = TestImageCache()
        let sessionMock = URLSessionMock(returnData: ImageHelper.testImageData, response: HTTPURLResponse.successResponse(with: TestData.urlFromEmail))
        let service = avatarService(with: sessionMock, cache: cache)
        let options = ImageDownloadOptions(forceRefresh: true)

        _ = try await service.fetch(with: .email(TestData.email), options: options)
        _ = try await service.fetch(with: .email(TestData.email), options: options)
        _ = try await service.fetch(with: .email(TestData.email), options: options)

        XCTAssertEqual(cache.getImageCallCount, 0, "We should not hit the cache")
        XCTAssertEqual(cache.setImageCallsCount, 3, "We should have cached the image on every forced refresh")
        XCTAssertEqual(sessionMock.callsCount, 3, "We should fetch from network")
    }

    func testForceRefreshDisabled() async throws {
        let cache = TestImageCache()
        let sessionMock = URLSessionMock(returnData: ImageHelper.testImageData, response: HTTPURLResponse.successResponse(with: TestData.urlFromEmail))
        let service = avatarService(with: sessionMock, cache: cache)
        let options = ImageDownloadOptions(forceRefresh: false)

        _ = try await service.fetch(with: .email(TestData.email), options: options)
        _ = try await service.fetch(with: .email(TestData.email), options: options)
        _ = try await service.fetch(with: .email(TestData.email), options: options)

        XCTAssertEqual(cache.getImageCallCount, 3, "We should hit the cache")
        XCTAssertEqual(cache.setImageCallsCount, 1, "We should save once to the cache")
        XCTAssertEqual(sessionMock.callsCount, 1, "We should fetch from network only the first time")
    }

    func testAlternativeImageProcessor() async throws {
        let response = HTTPURLResponse.successResponse(with: TestData.urlFromEmail)
        let sessionMock = URLSessionMock(returnData: ImageHelper.testImageData, response: response)
        let service = avatarService(with: sessionMock)
        let testProcessor = TestImageProcessor()
        let options = ImageDownloadOptions(processingMethod: .custom(processor: testProcessor))

        _ = try await service.fetch(with: .email(TestData.email), options: options)

        XCTAssertTrue(testProcessor.processedData)
    }

    func testFetchImageWithDefaultImageOption() async throws {
        let expectedQuery = "d=mp"
        let urlWithQuery = TestData.urlFromEmail.absoluteString + "?" + expectedQuery
        let response = HTTPURLResponse.successResponse(with: URL(string: urlWithQuery)!)
        let sessionMock = URLSessionMock(returnData: ImageHelper.testImageData, response: response)
        let service = avatarService(with: sessionMock)
        let options = ImageDownloadOptions(defaultAvatarOption: .mysteryPerson)

        let imageResponse = try await service.fetch(with: .email(TestData.email), options: options)

        XCTAssertEqual(sessionMock.request?.url?.query, expectedQuery)
        XCTAssertNotNil(imageResponse.image)
    }
}

private func avatarService(with session: URLSessionProtocol, cache: ImageCaching? = nil) -> AvatarService {
    let client = URLSessionHTTPClient(urlSession: session)
    let service = AvatarService(client: client, cache: cache)
    return service
}

extension HTTPURLResponse {
    static func successResponse(with url: URL? = URL(string: "https://gravatar.com")) -> HTTPURLResponse {
        HTTPURLResponse(url: url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
    }

    static func errorResponse(with url: URL? = URL(string: "https://gravatar.com"), code: Int) -> HTTPURLResponse {
        HTTPURLResponse(url: url!, statusCode: code, httpVersion: nil, headerFields: nil)!
    }
}
