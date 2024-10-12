import Gravatar
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
    }

    func testUploadImageError() async throws {
        let responseCode = 408
        let errorResponse = HTTPURLResponse.errorResponse(code: responseCode)
        let sessionMock = URLSessionMock(returnData: "Error".data(using: .utf8)!, response: errorResponse)
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

        let setImageCallsCount = cache.setImageCallsCount
        let getImageCallsCount = cache.getImageCallsCount
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

        let setImageCallsCount = cache.setImageCallsCount
        let getImageCallsCount = cache.getImageCallsCount
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

    // MARK: - Upload Tests using deprecated v1 API

    func testV1UploadImage() async throws {
        let successResponse = HTTPURLResponse.successResponse()
        let sessionMock = URLSessionMock(returnData: "Success".data(using: .utf8)!, response: successResponse)
        let service = avatarService(with: sessionMock)

        let _ = try await service.upload(ImageHelper.testImage, email: Email(TestData.email), accessToken: "AccessToken")
        let data = await sessionMock.uploadData
        let uploadData = try XCTUnwrap(data)
        XCTAssertTrue(
            String(data: uploadData, encoding: .isoLatin1)!.contains(TestData.email),
            "Multipart form data should use the raw email address instead of its hash"
        )
        let request = await sessionMock.request
        XCTAssertEqual(request?.url?.absoluteString, "https://api.gravatar.com/v1/upload-image")
        XCTAssertNotNil(request?.value(forHTTPHeaderField: "Authorization"))
        XCTAssertEqual(request?.value(forHTTPHeaderField: "Authorization"), "Bearer AccessToken")
        XCTAssertNotNil(request?.value(forHTTPHeaderField: "Content-Type"))
        XCTAssertTrue(request?.value(forHTTPHeaderField: "Content-Type")?.hasPrefix("multipart/form-data; boundary=") ?? false)
    }

    func testV1UploadImageError() async throws {
        let responseCode = 408
        let successResponse = HTTPURLResponse.errorResponse(code: responseCode)
        let sessionMock = URLSessionMock(returnData: "Error".data(using: .utf8)!, response: successResponse)
        let service = avatarService(with: sessionMock)

        do {
            let _ = try await service.upload(ImageHelper.testImage, email: Email(TestData.email), accessToken: "AccessToken")
            XCTFail("This should throw an error")
        } catch ImageUploadError.responseError(reason: let reason) where reason.httpStatusCode == responseCode {
            // Expected error has occurred.
        } catch {
            XCTFail("This should have thrown an invalidHTTPStatusCode with:\(responseCode)")
        }
    }

    func testV1UploadImageDataError() async throws {
        let successResponse = HTTPURLResponse.errorResponse(code: 408)
        let sessionMock = URLSessionMock(returnData: "Error".data(using: .utf8)!, response: successResponse)
        let service = avatarService(with: sessionMock)

        do {
            let _ = try await service.upload(UIImage(), email: Email(TestData.email), accessToken: "AccessToken")
            XCTFail("This should throw an error")
        } catch let error as ImageUploadError {
            XCTAssertEqual(error, ImageUploadError.cannotConvertImageIntoData)
        }
    }
}

private func avatarService(with session: URLSessionProtocol, cache: ImageCaching? = nil) -> AvatarService {
    let service = AvatarService(urlSession: session, cache: cache)
    return service
}
