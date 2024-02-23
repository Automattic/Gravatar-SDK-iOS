@testable import Gravatar
import XCTest

final class ImageServiceTests: XCTestCase {
    enum TestData {
        static let email = "some@email.com"
        static let urlFromEmail = URL(string: "https://gravatar.com/avatar/676212ff796c79a3c06261eb10e3f455aa93998ee6e45263da13679c74b1e674")!
    }

    func testFetchImage() async throws {
        let response = HTTPURLResponse.successResponse(with: TestData.urlFromEmail)
        let sessionMock = URLSessionMock(returnData: ImageHelper.testImageData, response: response)
        let service = imageService(with: sessionMock)
        let options = GravatarImageDownloadOptions()

        let imageResponse = try await service.fetchImage(with: TestData.email, options: options)

        XCTAssertEqual(sessionMock.request?.url, TestData.urlFromEmail)
        XCTAssertNotNil(imageResponse.image)
    }

    func testFetchImageWithCompletionHandler() {
        let response = HTTPURLResponse.successResponse(with: TestData.urlFromEmail)
        let sessionMock = URLSessionMock(returnData: ImageHelper.testImageData, response: response)
        let service = imageService(with: sessionMock)
        let expectation = expectation(description: "Request finishes")

        service.fetchImage(with: TestData.email) { response in
            switch response {
            case .success(let result):
                XCTAssertNotNil(result.image)
            case .failure(let error):
                XCTFail(error.localizedDescription)
            }
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 0.2)
    }

    func testFetchImageWithCompletionHandlerError() {
        let response = HTTPURLResponse.errorResponse(code: 404)
        let sessionMock = URLSessionMock(returnData: ImageHelper.testImageData, response: response)
        let service = imageService(with: sessionMock)
        let expectation = expectation(description: "Request finishes")

        service.fetchImage(with: TestData.urlFromEmail) { response in
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

    func testFetchImageWithURL() async throws {
        let imageURL = "https://gravatar.com/avatar/HASH"
        let response = HTTPURLResponse.successResponse(with: URL(string: imageURL)!)
        let sessionMock = URLSessionMock(returnData: ImageHelper.testImageData, response: response)
        let service = imageService(with: sessionMock)

        let imageResponse = try await service.fetchImage(with: URL(string: imageURL)!)

        XCTAssertEqual(sessionMock.request?.url?.absoluteString, "https://gravatar.com/avatar/HASH")
        XCTAssertNotNil(imageResponse.image)
    }

    func testFetchImageWithCompletionHandlerAndURL() {
        let imageURL = "https://gravatar.com/avatar/HASH"
        let response = HTTPURLResponse.successResponse(with: URL(string: imageURL))
        let sessionMock = URLSessionMock(returnData: ImageHelper.testImageData, response: response)
        let service = imageService(with: sessionMock)
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

    func testFetchCatchedImageWithURL() async throws {
        let imageURL = "https://gravatar.com/avatar/HASH"
        let response = HTTPURLResponse.successResponse(with: URL(string: imageURL)!)
        let sessionMock = URLSessionMock(returnData: ImageHelper.testImageData, response: response)
        let cache = TestImageCache()
        let service = imageService(with: sessionMock, cache: cache)

        _ = try await service.fetchImage(with: URL(string: imageURL)!)
        _ = try await service.fetchImage(with: URL(string: imageURL)!)
        let imageResponse = try await service.fetchImage(with: URL(string: imageURL)!)

        XCTAssertEqual(cache.setImageCallsCount, 1)
        XCTAssertEqual(cache.getImageCallCount, 3)
        XCTAssertEqual(sessionMock.callsCount, 1)
        XCTAssertEqual(sessionMock.request?.url?.absoluteString, "https://gravatar.com/avatar/HASH")
        XCTAssertNotNil(imageResponse.image)
    }

    func testUploadImage() async throws {
        let successResponse = HTTPURLResponse.successResponse()
        let sessionMock = URLSessionMock(returnData: "Success".data(using: .utf8)!, response: successResponse)
        let service = imageService(with: sessionMock)

        try await service.uploadImage(ImageHelper.testImage, accountEmail: "some@email.com", accountToken: "AccessToken")

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
        let service = imageService(with: sessionMock)

        do {
            try await service.uploadImage(ImageHelper.testImage, accountEmail: "some@email.com", accountToken: "AccessToken")
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
        let service = imageService(with: sessionMock)

        do {
            try await service.uploadImage(UIImage(), accountEmail: "some@email.com", accountToken: "AccessToken")
            XCTFail("This should throw an error")
        } catch let error as ImageUploadError {
            XCTAssertEqual(error, ImageUploadError.cannotConvertImageIntoData)
        }
    }

    func testUploadImageWithCompletionHandler() {
        let successResponse = HTTPURLResponse.successResponse(with: URL(string: "http://gravatar.com"))
        let sessionMock = URLSessionMock(returnData: "Success".data(using: .utf8)!, response: successResponse)
        let service = imageService(with: sessionMock)
        let expectation = expectation(description: "Should succeed")

        service.uploadImage(ImageHelper.testImage, accountEmail: "some@email.com", accountToken: "AccessToken") { error in
            XCTAssertNil(error)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 0.1)
    }

    func testUploadImageWithCompletionHandlerError() {
        let responseCode = 415
        let successResponse = HTTPURLResponse.errorResponse(with: URL(string: "http://gravatar.com"), code: responseCode)
        let sessionMock = URLSessionMock(returnData: "Error".data(using: .utf8)!, response: successResponse)
        let service = imageService(with: sessionMock)
        let expectation = expectation(description: "Should error")

        service.uploadImage(ImageHelper.testImage, accountEmail: "some@email.com", accountToken: "AccessToken") { error in
            switch error {
            case .some(ImageUploadError.responseError(reason: let reason)) where reason.httpStatusCode == responseCode:
                break
            default:
                XCTFail("This should have thrown an invalidHTTPStatusCode with:\(responseCode)")
            }
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 0.1)
    }

    func testForceRefreshEnabled() async throws {
        let cache = TestImageCache()
        let sessionMock = URLSessionMock(returnData: ImageHelper.testImageData, response: HTTPURLResponse.successResponse(with: TestData.urlFromEmail))
        let service = imageService(with: sessionMock, cache: cache)
        let options = GravatarImageDownloadOptions(forceRefresh: true)

        _ = try await service.fetchImage(with: TestData.email, options: options)
        _ = try await service.fetchImage(with: TestData.email, options: options)
        _ = try await service.fetchImage(with: TestData.email, options: options)

        XCTAssertEqual(cache.getImageCallCount, 0, "We should not hit the cache")
        XCTAssertEqual(cache.setImageCallsCount, 3, "We should have cached the image on every forced refresh")
        XCTAssertEqual(sessionMock.callsCount, 3, "We should fetch from network")
    }

    func testForceRefreshDisabled() async throws {
        let cache = TestImageCache()
        let sessionMock = URLSessionMock(returnData: ImageHelper.testImageData, response: HTTPURLResponse.successResponse(with: TestData.urlFromEmail))
        let service = imageService(with: sessionMock, cache: cache)
        let options = GravatarImageDownloadOptions(forceRefresh: false)

        _ = try await service.fetchImage(with: TestData.email, options: options)
        _ = try await service.fetchImage(with: TestData.email, options: options)
        _ = try await service.fetchImage(with: TestData.email, options: options)

        XCTAssertEqual(cache.getImageCallCount, 3, "We should hit the cache")
        XCTAssertEqual(cache.setImageCallsCount, 1, "We should save once to the cache")
        XCTAssertEqual(sessionMock.callsCount, 1, "We should fetch from network only the first time")
    }

    func testAlternativeImageProcessor() async throws {
        let response = HTTPURLResponse.successResponse(with: TestData.urlFromEmail)
        let sessionMock = URLSessionMock(returnData: ImageHelper.testImageData, response: response)
        let service = imageService(with: sessionMock)
        let testProcessor = TestImageProcessor()
        let options = GravatarImageDownloadOptions(processingMethod: .custom(processor: testProcessor))

        _ = try await service.fetchImage(with: TestData.email, options: options)

        XCTAssertTrue(testProcessor.processedData)
    }

    func testFetchImageWithDefaultImageOption() async throws {
        let expectedQuery = "d=mp"
        let urlWithQuery = TestData.urlFromEmail.absoluteString + "?" + expectedQuery
        let response = HTTPURLResponse.successResponse(with: URL(string: urlWithQuery)!)
        let sessionMock = URLSessionMock(returnData: ImageHelper.testImageData, response: response)
        let service = imageService(with: sessionMock)
        let options = GravatarImageDownloadOptions(defaultImage: .misteryPerson)

        let imageResponse = try await service.fetchImage(with: TestData.email, options: options)

        XCTAssertEqual(sessionMock.request?.url?.query, expectedQuery)
        XCTAssertNotNil(imageResponse.image)
    }
}

private func imageService(with session: URLSessionProtocol, cache: GravatarImageCaching = GravatarImageCache()) -> ImageService {
    let client = URLSessionHTTPClient(urlSession: session)
    let service = ImageService(client: client, cache: cache)
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
