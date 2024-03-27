import Gravatar
import XCTest

@MainActor
final class GravatarWrapper_UIImageViewTests: XCTestCase {
    let frame = CGRect(x: 0, y: 0, width: 50, height: 50)

    func testActivityLoaderStarts() async throws {
        let imageView = UIImageView(frame: frame)
        let activityIndicator = TestActivityIndicator()
        imageView.gravatar.activityIndicatorType = .custom(activityIndicator)

        try await imageView.gravatar.setImage(
            email: "hello@gmail.com",
            options: [.imageDownloader(TestImageFetcher(result: .success))]
        )
        XCTAssertTrue(activityIndicator.counter == 1)
    }

    func testActivityLoaderStopsOnSuccess() async throws {
        let imageView = UIImageView(frame: frame)
        let activityIndicator = TestActivityIndicator()
        let imageRetriever = TestImageFetcher(result: .success)

        imageView.gravatar.activityIndicatorType = .custom(activityIndicator)
        try await imageView.gravatar.setImage(
            email: "hello@gmail.com",
            options: [.imageDownloader(imageRetriever)]
        )
        XCTAssertFalse(activityIndicator.animating)
    }

    func testActivityLoaderStopsOnFail() async {
        let imageView = UIImageView(frame: frame)
        let activityIndicator = TestActivityIndicator()
        let imageRetriever = TestImageFetcher(result: .fail)

        imageView.gravatar.activityIndicatorType = .custom(activityIndicator)
        do {
            try await imageView.gravatar.setImage(
                email: "hello@gmail.com",
                options: [.imageDownloader(imageRetriever)]
            )
        } catch {
            XCTAssertFalse(activityIndicator.animating)
        }
    }

    func testIfPlaceholderIsSet() async {
        let imageView = UIImageView(frame: frame)
        let imageRetriever = TestImageFetcher(result: .fail)

        do {
            try await imageView.gravatar.setImage(
                email: "hello@gmail.com",
                placeholder: ImageHelper.placeholderImage,
                options: [.imageDownloader(imageRetriever)]
            )
        } catch {
            XCTAssertNotNil(imageView.gravatar.placeholder)
        }
    }

    func testDefaultAvatarOptionIsSet() async throws {
        let expectedQueryItemString = "d=robohash"

        let imageView = UIImageView(frame: frame)
        let imageDownloader = TestImageFetcher(result: .success)

        let result = try await imageView.gravatar.setImage(
            email: "hello@gmail.com",
            defaultAvatarOption: .roboHash,
            options: [.imageDownloader(imageDownloader)]
        )
        let query = result.sourceURL.query ?? ""
        let urlContainsDefaultImageOption = query.contains(expectedQueryItemString)
        XCTAssertTrue(urlContainsDefaultImageOption, "\(query) does not contain \(expectedQueryItemString)")
    }

    func testIfPlaceholderIsSetWithNilURL() async throws {
        let imageView = UIImageView(frame: frame)
        let imageRetriever = TestImageFetcher(result: .fail)

        do {
            try await imageView.gravatar.setImage(
                with: nil,
                placeholder: ImageHelper.placeholderImage,
                options: [.imageDownloader(imageRetriever)]
            )
        } catch {
            XCTAssertNotNil(imageView.gravatar.placeholder)
        }
    }

    func testRemoveCurrentImageWhileLoadingNoPlaceholder() async throws {
        let imageView = UIImageView(frame: frame)
        imageView.image = ImageHelper.testImage
        let imageRetriever = TestImageFetcher(result: .fail)

        do {
            try await imageView.gravatar.setImage(
                email: "hello@gmail.com",
                options: [.imageDownloader(imageRetriever),
                          .removeCurrentImageWhileLoading]
            )
        } catch {
            XCTAssertNil(imageView.image)
        }
    }

    func testRemoveCurrentImageWhileLoadingWithPlaceholder() async throws {
        let imageView = UIImageView(frame: frame)
        imageView.image = ImageHelper.testImage
        let imageRetriever = TestImageFetcher(result: .fail)
        let placeholder = ImageHelper.placeholderImage

        do {
            try await imageView.gravatar.setImage(
                email: "hello@gmail.com",
                placeholder: placeholder,
                options: [.imageDownloader(imageRetriever),
                          .removeCurrentImageWhileLoading]
            )
        } catch {
            XCTAssertEqual(imageView.image, placeholder)
            XCTAssertEqual(imageView.gravatar.placeholder, placeholder)
        }
    }

    func testNotCurrentSourceTaskResult() async throws {
        let imageView = UIImageView(frame: frame)
        let imageRetriever = TestImageFetcher(result: .success)

        let task1 = Task {
            do {
                try await imageView.gravatar.setImage(
                    with: URL(string: "https://first.com"),
                    options: [.imageDownloader(imageRetriever)]
                )
            } catch ImageFetchingComponentError.outdatedTask(.success(_), let source) {
                XCTAssertEqual(source.absoluteString, "https://first.com")
            } catch {
                XCTFail()
            }
        }
        await Task.yield()

        let task2 = Task {
            do {
                let result = try await imageView.gravatar.setImage(
                    with: URL(string: "https://second.com"),
                    options: [.imageDownloader(imageRetriever)]
                )
                XCTAssertEqual(result.sourceURL.absoluteString, "https://second.com")
            } catch {
                XCTFail()
            }
        }
        await task2.value
        await task1.value
    }
}
