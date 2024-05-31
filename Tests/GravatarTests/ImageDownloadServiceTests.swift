@testable import Gravatar
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

    func testFetchImageCancel() async throws {
        let imageURL = try XCTUnwrap(URL(string: "https://gravatar.com/avatar/HASH"))
        let response = HTTPURLResponse.successResponse(with: imageURL)
        let sessionMock = URLSessionMock(returnData: ImageHelper.testImageData, response: response)
        await sessionMock.update(isCancellable: true)
        let service = imageDownloadService(with: sessionMock)

        let task1 = Task {
            do {
                let _ = try await service.fetchImage(with: imageURL)
                XCTFail()
            } catch ImageFetchingError.responseError(reason: .URLSessionError(error: let error)) {
                XCTAssertNotNil(error as? CancellationError)
            } catch {
                XCTFail()
            }
        }

        let task2 = Task {
            try await Task.sleep(nanoseconds: UInt64(0.05 * 1_000_000_000))
            await service.cancelTask(for: imageURL)
        }

        await task1.value
        try await task2.value
    }

    func testCallAfterAFailedCallWorksFine() async throws {
        let imageURL = try XCTUnwrap(URL(string: "https://gravatar.com/avatar/HASH"))
        let response = HTTPURLResponse.successResponse(with: imageURL)
        let sessionMock = URLSessionMock(returnData: ImageHelper.testImageData, response: response)
        await sessionMock.update(isCancellable: true)
        let service = imageDownloadService(with: sessionMock)

        let task1 = Task {
            do {
                let _ = try await service.fetchImage(with: imageURL)
                XCTFail()
            } catch ImageFetchingError.responseError(reason: .URLSessionError(error: let error)) {
                XCTAssertNotNil(error as? CancellationError)
            } catch {
                XCTFail()
            }
        }

        let task2 = Task {
            try await Task.sleep(nanoseconds: UInt64(0.1 * 1_000_000_000))
            await service.cancelTask(for: imageURL)
        }

        await task1.value
        try await task2.value

        // The task is cancelled, now we retry and it should succeed.
        await sessionMock.update(isCancellable: false)
        let result = try await service.fetchImage(with: imageURL)
        XCTAssertNotNil(result.image)
    }

    func testImageProcessingError() async throws {
        let imageURL = try XCTUnwrap(URL(string: "https://gravatar.com/avatar/HASH"))
        let response = HTTPURLResponse.successResponse(with: imageURL)
        let sessionMock = URLSessionMock(returnData: ImageHelper.testImageData, response: response)
        let cache = TestImageCache()
        let service = imageDownloadService(with: sessionMock, cache: cache)

        do {
            _ = try await service.fetchImage(with: imageURL, processingMethod: .custom(processor: FailingImageProcessor()))
            XCTFail()
        } catch ImageFetchingError.imageProcessorFailed {
            // success
        } catch {
            XCTFail()
        }
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
