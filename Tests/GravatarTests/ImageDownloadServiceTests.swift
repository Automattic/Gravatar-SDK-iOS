@testable import Gravatar
import TestHelpers
import XCTest

final class ImageDownloadServiceTests: XCTestCase {
    func testFetchImageWithURL() async throws {
        let imageURL = "https://gravatar.com/avatar/HASH"
        let response = HTTPURLResponse.successResponse(with: URL(string: imageURL)!)
        let sessionMock = URLSessionMock(returnData: ImageHelper.testImageData, response: response)
        let service = imageDownloadService(with: sessionMock, cache: TestImageCache())

        let imageResponse = try await service.fetchImage(with: URL(string: imageURL)!)
        let request = await sessionMock.request
        XCTAssertEqual(request?.url?.absoluteString, "https://gravatar.com/avatar/HASH")
        XCTAssertNotNil(imageResponse.image)
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
        let setImageCallsCount = cache.setImageCallsCount
        let setTaskCallCount = cache.setTaskCallsCount
        let getImageCallsCount = cache.getImageCallsCount
        let request = await sessionMock.request
        let callsCount = await sessionMock.callsCount
        XCTAssertEqual(setImageCallsCount, 1)
        XCTAssertEqual(setTaskCallCount, 1)
        XCTAssertEqual(getImageCallsCount, 3)
        XCTAssertEqual(callsCount, 1)
        XCTAssertEqual(request?.url?.absoluteString, "https://gravatar.com/avatar/HASH")
        XCTAssertNotNil(imageResponse.image)
    }

    func testFetchImageCancel() async throws {
        let imageURL = try XCTUnwrap(URL(string: "https://gravatar.com/avatar/HASH"))
        let response = HTTPURLResponse.successResponse(with: imageURL)
        let sessionMock = URLSessionMock(returnData: ImageHelper.testImageData, response: response)
        await sessionMock.update(isCancellable: true)
        let cache = TestImageCache()
        let service = imageDownloadService(with: sessionMock, cache: cache)

        let task1 = Task {
            do {
                let _ = try await service.fetchImage(with: imageURL)
                XCTFail()
            } catch {
                XCTAssertNotNil(error as? CancellationError)
                let entry = cache.getEntry(with: imageURL.absoluteString)
                XCTAssertNil(entry)
            }
        }

        try await Task.sleep(nanoseconds: UInt64(0.05 * 1_000_000_000))
        task1.cancel()

        await task1.value
    }

    func testCallAfterAFailedCallWorksFine() async throws {
        let cache = TestImageCache()

        let imageURL = try XCTUnwrap(URL(string: "https://gravatar.com/avatar/HASH"))
        let response = HTTPURLResponse.successResponse(with: imageURL)
        let sessionMock = URLSessionMock(returnData: ImageHelper.testImageData, response: response, error: NSError(domain: "test", code: 1))
        await sessionMock.update(isCancellable: true)
        let service = imageDownloadService(with: sessionMock, cache: cache)
        let task1 = Task {
            do {
                let _ = try await service.fetchImage(with: imageURL)
                XCTFail()
            } catch {
                XCTAssertNotNil(error)
                let entry = cache.getEntry(with: imageURL.absoluteString)
                XCTAssertNil(entry)
            }
        }

        await task1.value

        // The task has failed, now we retry and it should succeed.
        await sessionMock.update(isCancellable: false)
        await sessionMock.update(error: nil)
        let result = try await service.fetchImage(with: imageURL)
        XCTAssertNotNil(result.image)
    }

    func testSimultaneousFetchShouldOnlyTriggerOneNetworkRequest() async throws {
        let imageURL = URL(string: "https://example.com/image.png")!

        let mockImageData = UIImage(systemName: "iphone.gen2")!.pngData()!

        let sessionMock = URLSessionMock(
            returnData: mockImageData,
            response: HTTPURLResponse.successResponse(with: imageURL)
        )

        // Simulate download tasks that have a longer duration
        await sessionMock.update(isCancellable: true)

        let cache = TestImageCache()
        let service = imageDownloadService(with: sessionMock, cache: cache)

        let expectation = XCTestExpectation(description: "Image fetches should complete")

        // When
        // Start simultaneous fetches
        let fetchTask1 = Task { try await service.fetchImage(with: imageURL, forceRefresh: false) }
        let fetchTask2 = Task { try await service.fetchImage(with: imageURL, forceRefresh: false) }
        let fetchTask3 = Task { try await service.fetchImage(with: imageURL, forceRefresh: false) }
        let fetchTask4 = Task { try await service.fetchImage(with: imageURL, forceRefresh: false) }
        let fetchTask5 = Task { try await service.fetchImage(with: imageURL, forceRefresh: false) }

        // Then
        let result1 = try await fetchTask1.value
        let result2 = try await fetchTask2.value
        let result3 = try await fetchTask3.value
        let result4 = try await fetchTask4.value
        let result5 = try await fetchTask5.value

        expectation.fulfill()
        await fulfillment(of: [expectation], timeout: 0.5)

        // Assert that all fetches return the same image
        XCTAssertEqual(result1.image.pngData(), mockImageData)
        XCTAssertEqual(result2.image.pngData(), mockImageData)
        XCTAssertEqual(result3.image.pngData(), mockImageData)
        XCTAssertEqual(result4.image.pngData(), mockImageData)
        XCTAssertEqual(result5.image.pngData(), mockImageData)

        // Assert that all fetches attempted to read from the cache
        XCTAssertEqual(cache.messageCount(type: .get), 5)

        // Assert that only one fetch set an `.inProgress` CacheEntry
        XCTAssertEqual(cache.messageCount(type: .inProgress, forKey: imageURL.absoluteString), 1)

        // Assert that only one fetch set an `.ready` CacheEntry
        XCTAssertEqual(cache.messageCount(type: .ready, forKey: imageURL.absoluteString), 1)
    }

    func testSimultaneousFetchShouldOnlyTriggerOneNetworkRequestPerUrl() async throws {
        let imageURL1 = URL(string: "https://example.com/image1.png")!
        let imageURL2 = URL(string: "https://example.com/image2.png")!

        let mockImageData = UIImage(systemName: "iphone.gen2")!.pngData()!

        let sessionMock = URLSessionMock(
            returnData: mockImageData,
            response: HTTPURLResponse()
        )

        let cache = TestImageCache()
        let service = imageDownloadService(with: sessionMock, cache: cache)

        let expectation = XCTestExpectation(description: "Image fetches should complete")

        // When
        // Start simultaneous fetches
        let fetchTask1 = Task { try await service.fetchImage(with: imageURL1, forceRefresh: false) }
        let fetchTask2 = Task { try await service.fetchImage(with: imageURL2, forceRefresh: false) }
        let fetchTask3 = Task { try await service.fetchImage(with: imageURL1, forceRefresh: false) }
        let fetchTask4 = Task { try await service.fetchImage(with: imageURL2, forceRefresh: false) }
        let fetchTask5 = Task { try await service.fetchImage(with: imageURL1, forceRefresh: false) }
        let fetchTask6 = Task { try await service.fetchImage(with: imageURL2, forceRefresh: false) }

        // Then
        let result1 = try await fetchTask1.value
        let result2 = try await fetchTask2.value
        let result3 = try await fetchTask3.value
        let result4 = try await fetchTask4.value
        let result5 = try await fetchTask5.value
        let result6 = try await fetchTask6.value

        expectation.fulfill()
        await fulfillment(of: [expectation], timeout: 0.5)

        // Assert that all fetches return the same image
        XCTAssertEqual(result1.image.pngData(), mockImageData)
        XCTAssertEqual(result2.image.pngData(), mockImageData)
        XCTAssertEqual(result3.image.pngData(), mockImageData)
        XCTAssertEqual(result4.image.pngData(), mockImageData)
        XCTAssertEqual(result5.image.pngData(), mockImageData)
        XCTAssertEqual(result6.image.pngData(), mockImageData)

        // Assert that all fetches attempted to read from the cache
        XCTAssertEqual(
            cache.messageCount(type: .get),
            6,
            "All fetches should have attempted to read from the cache"
        )
        XCTAssertEqual(
            cache.messageCount(type: .get, forKey: imageURL1.absoluteString), 3,
            "All fetches for '\(imageURL1)' should have attempted to read from the cache"
        )
        XCTAssertEqual(
            cache.messageCount(type: .get, forKey: imageURL2.absoluteString), 3,
            "All fetches for '\(imageURL2)' should have attempted to read from the cache"
        )

        // Assert that only one fetch set an `.inProgress` CacheEntry
        XCTAssertEqual(
            cache.messageCount(type: .inProgress, forKey: imageURL1.absoluteString),
            1,
            "Only one fetch for '\(imageURL1)' should have set an `.inProgress` CacheEntry"
        )
        XCTAssertEqual(
            cache.messageCount(type: .inProgress, forKey: imageURL2.absoluteString),
            1,
            "Only one fetch for '\(imageURL2)' should have set an `.inProgress` CacheEntry"
        )

        // Assert that only one fetch set an `.ready` CacheEntry
        XCTAssertEqual(
            cache.messageCount(type: .ready, forKey: imageURL1.absoluteString),
            1,
            "Only one fetch for '\(imageURL1)' should have set a `.ready` CacheEntry"
        )
        XCTAssertEqual(
            cache.messageCount(type: .ready, forKey: imageURL2.absoluteString),
            1,
            "Only one fetch for '\(imageURL2)' should have set a `.ready` CacheEntry"
        )
    }
}

private func imageDownloadService(with session: URLSessionProtocol, cache: ImageCaching? = nil) -> ImageDownloadService {
    let client = URLSessionHTTPClient(urlSession: session)
    let service = ImageDownloadService(client: client, cache: cache)
    return service
}
