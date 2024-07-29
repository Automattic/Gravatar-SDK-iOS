import Gravatar
import GravatarUI
@testable import TestHelpers
import XCTest

final class GravatarWrapper_UIImageViewTests: XCTestCase {
    let frame = CGRect(x: 0, y: 0, width: 50, height: 50)

    @MainActor
    func testActivityLoaderStopsOnSuccess() async throws {
        let imageView = UIImageView(frame: frame)
        let activityIndicator = TestActivityIndicator()
        let imageRetriever = TestImageFetcher(result: .success)
        imageView.gravatar.activityIndicatorType = .custom(activityIndicator)
        try await imageView.gravatar.setImage(
            avatarID: .email("hello@gmail.com"),
            options: [.imageDownloader(imageRetriever)]
        )
        XCTAssertEqual(activityIndicator.startCount, 1)
        XCTAssertEqual(activityIndicator.stopCount, 1)
        XCTAssertFalse(activityIndicator.animating)
    }

    @MainActor
    func testActivityLoaderStopsOnFail() async throws {
        let imageView = UIImageView(frame: frame)
        let activityIndicator = TestActivityIndicator()
        let imageRetriever = TestImageFetcher(result: .fail)

        imageView.gravatar.activityIndicatorType = .custom(activityIndicator)
        do {
            try await imageView.gravatar.setImage(
                avatarID: .email("hello@gmail.com"),
                options: [.imageDownloader(imageRetriever)]
            )
        } catch {}
        XCTAssertEqual(activityIndicator.startCount, 1)
        XCTAssertEqual(activityIndicator.stopCount, 1)
        XCTAssertFalse(activityIndicator.animating)
    }

    @MainActor
    func testIfPlaceholderIsSet() async throws {
        let imageView = UIImageView(frame: frame)
        let imageRetriever = TestImageFetcher(result: .fail)

        do {
            try await imageView.gravatar.setImage(
                avatarID: .email("hello@gmail.com"),
                placeholder: ImageHelper.placeholderImage,
                options: [.imageDownloader(imageRetriever)]
            )
        } catch {}
        XCTAssertNotNil(imageView.gravatar.placeholder)
    }

    @MainActor
    func testDefaultAvatarOptionIsSet() async throws {
        let expectedQueryItemString = "d=robohash"
        let imageView = UIImageView(frame: frame)
        let imageDownloader = TestImageFetcher(result: .success)

        let value = try await imageView.gravatar.setImage(
            avatarID: .email("hello@gmail.com"),
            defaultAvatarOption: .roboHash,
            options: [.imageDownloader(imageDownloader)]
        )
        let query = value.sourceURL.query ?? ""
        let urlContainsDefaultImageOption = query.contains(expectedQueryItemString)
        XCTAssertTrue(urlContainsDefaultImageOption, "\(query) does not contain \(expectedQueryItemString)")
    }

    @MainActor
    func testIfPlaceholderIsSetWithNilURL() async throws {
        let imageView = UIImageView(frame: frame)
        let imageRetriever = TestImageFetcher(result: .fail)
        do {
            try await imageView.gravatar.setImage(
                with: nil,
                placeholder: ImageHelper.placeholderImage,
                options: [.imageDownloader(imageRetriever)]
            )
        } catch {}
        XCTAssertNotNil(imageView.gravatar.placeholder)
    }

    @MainActor
    func testCancelOngoingDownload() async throws {
        let imageView = UIImageView(frame: frame)
        let cache = TestImageCache()

        let imageURL = try XCTUnwrap(URL(string: "https://gravatar.com/avatar/HASH"))
        let response = HTTPURLResponse.successResponse(with: imageURL)
        let sessionMock = URLSessionMock(returnData: ImageHelper.testImageData, response: response)
        await sessionMock.update(isCancellable: true)
        let imageDownloader = ImageDownloadService.mock(with: sessionMock, cache: cache)

        let task1 = Task {
            do {
                try await imageView.gravatar.setImage(
                    avatarID: .email("hello@gmail.com"),
                    options: [.imageDownloader(imageDownloader)]
                )
                XCTFail()
            } catch ImageFetchingComponentError.responseError(reason: .URLSessionError(error: let error)) {
                XCTAssertNotNil(error as? CancellationError)
            } catch {
                XCTFail()
            }
        }

        let task2 = Task {
            try await Task.sleep(nanoseconds: UInt64(0.1 * 1_000_000_000))
            await imageView.gravatar.cancelImageDownload()
        }

        await task1.value
        try await task2.value
    }

    @MainActor
    func testRemoveCurrentImageWhileLoadingNoPlaceholder() async throws {
        let imageView = UIImageView(frame: frame)
        imageView.image = ImageHelper.testImage
        let imageRetriever = TestImageFetcher(result: .fail)

        do {
            try await imageView.gravatar.setImage(
                avatarID: .email("hello@gmail.com"),
                options: [.imageDownloader(imageRetriever),
                          .removeCurrentImageWhileLoading]
            )
        } catch {}

        XCTAssertNil(imageView.image)
    }

    @MainActor
    func testRemoveCurrentImageWhileLoadingWithPlaceholder() async throws {
        let imageView = UIImageView(frame: frame)
        imageView.image = ImageHelper.testImage
        let imageRetriever = TestImageFetcher(result: .fail)
        let placeholder = ImageHelper.placeholderImage

        do {
            try await imageView.gravatar.setImage(
                avatarID: .email("hello@gmail.com"),
                placeholder: placeholder,
                options: [.imageDownloader(imageRetriever),
                          .removeCurrentImageWhileLoading]
            )
        } catch {}

        XCTAssertEqual(imageView.image, placeholder)
        XCTAssertEqual(imageView.gravatar.placeholder, placeholder)
    }

    @MainActor
    func testNotCurrentSourceTaskResult() async throws {
        let imageView = UIImageView(frame: frame)
        let cache = TestImageCache()

        let imageURL = try XCTUnwrap(URL(string: "https://gravatar.com/avatar/HASH"))
        let response = HTTPURLResponse.successResponse(with: imageURL)
        let sessionMock = URLSessionMock(returnData: ImageHelper.testImageData, response: response)
        await sessionMock.update(isCancellable: true)
        await sessionMock.update(maxDurationSeconds: 0.3)
        let imageDownloader = ImageDownloadService.mock(with: sessionMock, cache: cache)

        let task1 = Task {
            do {
                try await imageView.gravatar.setImage(
                    with: URL(string: "https://first.com"),
                    options: [.imageDownloader(imageDownloader)]
                )
                XCTFail()
            } catch ImageFetchingComponentError.outdatedTask(.success(let value), let source) {
                XCTAssertEqual(source.absoluteString, "https://first.com")
                XCTAssertNotNil(value.image) // We got the image for "http://first.com"
            } catch {
                XCTFail()
            }
        }

        let task2 = Task {
            do {
                try await Task.sleep(nanoseconds: UInt64(0.01 * 1_000_000_000))
                let value = try await imageView.gravatar.setImage(
                    with: URL(string: "https://second.com"),
                    options: [.imageDownloader(imageDownloader)]
                )
                XCTAssertEqual(value.sourceURL.absoluteString, "https://second.com")
            } catch {
                XCTFail()
            }
        }
        await task1.value
        await task2.value
    }
}
