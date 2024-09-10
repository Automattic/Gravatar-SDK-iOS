@testable import Gravatar
import TestHelpers
import XCTest

final class AvatarServiceTests: XCTestCase {
    enum TestData {
        static let email = "some@email.com"
        static let urlFromEmail = URL(string: "https://gravatar.com/avatar/676212ff796c79a3c06261eb10e3f455aa93998ee6e45263da13679c74b1e674")!
    }

    func testFetchImage() async throws {
        let response = HTTPURLResponse.successResponse(with: TestData.urlFromEmail)
        let sessionMock = URLSessionMock(returnData: ImageHelper.testImageData, response: response)
        let service = avatarService(with: sessionMock, cache: TestImageCache())
        let options = ImageDownloadOptions()

        let imageResponse = try await service.fetch(with: .email(TestData.email), options: options)
        let request = await sessionMock.request
        XCTAssertEqual(request?.url, TestData.urlFromEmail)
        XCTAssertNotNil(imageResponse.image)
    }

    func testUploadImage() async throws {
        let successResponse = HTTPURLResponse.successResponse()
        let sessionMock = URLSessionMock(returnData: Bundle.imageUploadJsonData!, response: successResponse)
        let service = avatarService(with: sessionMock)

        let avatar = try await service.upload(ImageHelper.testImage, accessToken: "AccessToken")

        XCTAssertEqual(avatar.id, "6f3eac1c67f970f2a0c2ea8")

        let request = await sessionMock.request
        XCTAssertEqual(request?.url?.absoluteString, "https://api.gravatar.com/v3/me/avatars")
        XCTAssertNotNil(request?.value(forHTTPHeaderField: "Authorization"))
        XCTAssertTrue(request?.value(forHTTPHeaderField: "Authorization")?.hasPrefix("Bearer ") ?? false)
        XCTAssertNotNil(request?.value(forHTTPHeaderField: "Content-Type"))
        XCTAssertTrue(request?.value(forHTTPHeaderField: "Content-Type")?.hasPrefix("multipart/form-data; boundary=") ?? false)
        XCTAssertTrue(request?.value(forHTTPHeaderField: "Client-Type") == "ios")
    }

    func testUploadImageError() async throws {
        let responseCode = 408
        let successResponse = HTTPURLResponse.errorResponse(code: responseCode)
        let sessionMock = URLSessionMock(returnData: "Error".data(using: .utf8)!, response: successResponse)
        let service = avatarService(with: sessionMock)

        do {
            try await service.upload(ImageHelper.testImage, accessToken: "AccessToken")
            XCTFail("This should throw an error")
        } catch ImageUploadError.responseError(reason: let reason) where reason.httpStatusCode == responseCode {
            // Expected error has occurred.
        } catch {
            XCTFail("This should have thrown an invalidHTTPStatusCode with:\(responseCode)")
        }
    }

    func testUploadImageDataError() async throws {
        let successResponse = HTTPURLResponse.errorResponse(code: 408)
        let sessionMock = URLSessionMock(returnData: "Error".data(using: .utf8)!, response: successResponse)
        let service = avatarService(with: sessionMock)

        do {
            try await service.upload(UIImage(), accessToken: "AccessToken")
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

        let setImageCallsCount = await cache.setImageCallsCount
        let getImageCallsCount = await cache.getImageCallsCount
        let callsCount = await sessionMock.callsCount
        XCTAssertEqual(getImageCallsCount, 0, "We should not hit the cache")
        XCTAssertEqual(setImageCallsCount, 3, "We should have cached the image on every forced refresh")
        XCTAssertEqual(callsCount, 3, "We should fetch from network")
    }

    func testForceRefreshDisabled() async throws {
        let cache = TestImageCache()
        let sessionMock = URLSessionMock(returnData: ImageHelper.testImageData, response: HTTPURLResponse.successResponse(with: TestData.urlFromEmail))
        let service = avatarService(with: sessionMock, cache: cache)
        let options = ImageDownloadOptions(forceRefresh: false)

        _ = try await service.fetch(with: .email(TestData.email), options: options)
        _ = try await service.fetch(with: .email(TestData.email), options: options)
        _ = try await service.fetch(with: .email(TestData.email), options: options)

        let setImageCallsCount = await cache.setImageCallsCount
        let getImageCallsCount = await cache.getImageCallsCount
        let callsCount = await sessionMock.callsCount
        XCTAssertEqual(getImageCallsCount, 3, "We should hit the cache")
        XCTAssertEqual(setImageCallsCount, 1, "We should save once to the cache")
        XCTAssertEqual(callsCount, 1, "We should fetch from network only the first time")
    }

    func testAlternativeImageProcessor() async throws {
        let response = HTTPURLResponse.successResponse(with: TestData.urlFromEmail)
        let sessionMock = URLSessionMock(returnData: ImageHelper.testImageData, response: response)
        let service = avatarService(with: sessionMock)
        let identifier = "Test"
        let testProcessor = TestImageProcessor(identifier: identifier)
        let options = ImageDownloadOptions(processingMethod: .custom(processor: testProcessor))

        let result = try await service.fetch(with: .email(TestData.email), options: options)

        XCTAssertTrue(result.image.accessibilityIdentifier == identifier)
    }

    func testFetchAvatarWithDefaultAvatarOption() async throws {
        let expectedQuery = "d=mp"
        let urlWithQuery = TestData.urlFromEmail.absoluteString + "?" + expectedQuery
        let response = HTTPURLResponse.successResponse(with: URL(string: urlWithQuery)!)
        let sessionMock = URLSessionMock(returnData: ImageHelper.testImageData, response: response)
        let service = avatarService(with: sessionMock)
        let options = ImageDownloadOptions(defaultAvatarOption: .mysteryPerson)

        let imageResponse = try await service.fetch(with: .email(TestData.email), options: options)
        let request = await sessionMock.request
        XCTAssertEqual(request?.url?.query, expectedQuery)
        XCTAssertNotNil(imageResponse.image)
    }
}

private func avatarService(with session: URLSessionProtocol, cache: ImageCaching? = nil) -> AvatarService {
    let client = URLSessionHTTPClient(urlSession: session)
    let service = AvatarService(client: client, cache: cache)
    return service
}
