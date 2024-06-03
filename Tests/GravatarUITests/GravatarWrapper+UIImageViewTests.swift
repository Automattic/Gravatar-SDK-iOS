import GravatarUI
@testable import TestHelpers
import XCTest

final class GravatarWrapper_UIImageViewTests: XCTestCase {
    let frame = CGRect(x: 0, y: 0, width: 50, height: 50)

    @MainActor
    func testActivityLoaderStopsOnSuccess() throws {
        let expectation = XCTestExpectation(description: "testActivityLoaderStopsOnSuccess")

        let imageView = UIImageView(frame: frame)
        let activityIndicator = TestActivityIndicator()
        let imageRetriever = TestImageFetcher(result: .success)

        imageView.gravatar.activityIndicatorType = .custom(activityIndicator)
        imageView.gravatar.setImage(
            avatarID: .email("hello@gmail.com"),
            options: [.imageDownloader(imageRetriever)]
        ) { _ in
            XCTAssertEqual(activityIndicator.startCount, 1)
            XCTAssertEqual(activityIndicator.stopCount, 1)
            XCTAssertFalse(activityIndicator.animating)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 2.0)
    }

    @MainActor
    func testActivityLoaderStopsOnFail() throws {
        let expectation = XCTestExpectation(description: "testActivityLoaderStopsOnFail")

        let imageView = UIImageView(frame: frame)
        let activityIndicator = TestActivityIndicator()
        let imageRetriever = TestImageFetcher(result: .fail)

        imageView.gravatar.activityIndicatorType = .custom(activityIndicator)
        imageView.gravatar.setImage(
            avatarID: .email("hello@gmail.com"),
            options: [.imageDownloader(imageRetriever)]
        ) { _ in
            XCTAssertEqual(activityIndicator.startCount, 1)
            XCTAssertEqual(activityIndicator.stopCount, 1)
            XCTAssertFalse(activityIndicator.animating)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 2.0)
    }

    @MainActor
    func testIfPlaceholderIsSet() throws {
        let expectation = XCTestExpectation(description: "testIfPlaceholderIsSet")

        let imageView = UIImageView(frame: frame)
        let imageRetriever = TestImageFetcher(result: .fail)

        imageView.gravatar.setImage(
            avatarID: .email("hello@gmail.com"),
            placeholder: ImageHelper.placeholderImage,
            options: [.imageDownloader(imageRetriever)]
        ) { _ in
            XCTAssertNotNil(imageView.gravatar.placeholder)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 2.0)
    }

    @MainActor
    func testDefaultAvatarOptionIsSet() throws {
        let expectedQueryItemString = "d=robohash"

        let imageView = UIImageView(frame: frame)
        let imageDownloader = TestImageFetcher(result: .success)

        imageView.gravatar.setImage(
            avatarID: .email("hello@gmail.com"),
            defaultAvatarOption: .roboHash,
            options: [.imageDownloader(imageDownloader)]
        ) { result in
            switch result {
            case .success(let value):
                let query = value.sourceURL.query ?? ""
                let urlContainsDefaultImageOption = query.contains(expectedQueryItemString)
                XCTAssertTrue(urlContainsDefaultImageOption, "\(query) does not contain \(expectedQueryItemString)")
            case .failure:
                XCTFail()
            }
        }
    }

    @MainActor
    func testIfPlaceholderIsSetWithNilURL() throws {
        let expectation = XCTestExpectation(description: "testIfPlaceholderIsSetWithNilURL")

        let imageView = UIImageView(frame: frame)
        let imageRetriever = TestImageFetcher(result: .fail)

        imageView.gravatar.setImage(
            with: nil,
            placeholder: ImageHelper.placeholderImage,
            options: [.imageDownloader(imageRetriever)]
        ) { _ in
            XCTAssertNotNil(imageView.gravatar.placeholder)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 2.0)
    }

    @MainActor
    func testCancelOngoingDownload() throws {
        let imageView = UIImageView(frame: frame)
        let imageRetriever = TestImageFetcher(result: .success)

        imageView.gravatar.setImage(
            avatarID: .email("hello@gmail.com"),
            options: [.imageDownloader(imageRetriever)]
        )

        let task = try XCTUnwrap(imageView.gravatar.downloadTask)

        imageView.gravatar.cancelImageDownload()

        XCTAssertTrue(task.isCancelled)
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
    func testNotCurrentSourceTaskResult() throws {
        let expectation = XCTestExpectation(description: "testNotCurrentSourceTaskResult")

        let imageView = UIImageView(frame: frame)
        let imageRetriever = TestImageFetcher(result: .success)

        let group = DispatchGroup()

        group.enter()
        // Pass .noResponse to simulate long lasting task
        imageView.gravatar.setImage(
            with: URL(string: "https://first.com"),
            options: [.imageDownloader(imageRetriever)]
        ) { result in
            switch result {
            case .failure(.outdatedTask(.success(let value), let source)):
                XCTAssertEqual(source.absoluteString, "https://first.com")
                XCTAssertNotNil(value.image) // We got the image for "http://first.com"
            default:
                XCTFail()
            }
            group.leave()
        }

        group.enter()
        // Start a new task before the previous one completes
        imageView.gravatar.setImage(
            with: URL(string: "https://second.com"),
            options: [.imageDownloader(imageRetriever)]
        ) { result in
            switch result {
            case .success(let value):
                XCTAssertEqual(value.sourceURL.absoluteString, "https://second.com")
            case .failure:
                XCTFail()
            }
            group.leave()
        }

        group.notify(queue: .main, execute: expectation.fulfill)
        wait(for: [expectation], timeout: 2.0)
    }
}
