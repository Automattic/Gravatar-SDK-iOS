//
//  GravatarWrapper+UIImageViewTests.swift
//
//
//  Created by Pinar Olguc on 26.01.2024.
//

import XCTest
import Gravatar

final class GravatarWrapper_UIImageViewTests: XCTestCase {

    let frame = CGRect(x: 0, y: 0, width: 50, height: 50)

    func testActivityLoaderStarts() throws {
        let imageView = UIImageView(frame: frame)
        let activityIndicator = TestActivityIndicator()
        
        imageView.gravatar.activityIndicatorType = .custom(activityIndicator)
        imageView.gravatar.setImage(email: "hello@gmail.com",
                                    options: [.imageDownloader(TestImageRetriever(result: .success))])
        XCTAssertTrue(activityIndicator.animating)
    }
    
    func testActivityLoaderStopsOnSuccess() throws {
        let expectation = XCTestExpectation(description: "testActivityLoaderStopsOnSuccess")

        let imageView = UIImageView(frame: frame)
        let activityIndicator = TestActivityIndicator()
        let imageRetriever = TestImageRetriever(result: .success)
        
        imageView.gravatar.activityIndicatorType = .custom(activityIndicator)
        imageView.gravatar.setImage(email: "hello@gmail.com",
                                    options: [.imageDownloader(imageRetriever)]) { result in
            XCTAssertFalse(activityIndicator.animating)
            expectation.fulfill()
        }
        imageRetriever.sendNextResponse()
        wait(for: [expectation], timeout: 2.0)
    }

    func testActivityLoaderStopsOnFail() throws {
        let expectation = XCTestExpectation(description: "testActivityLoaderStopsOnFail")

        let imageView = UIImageView(frame: frame)
        let activityIndicator = TestActivityIndicator()
        let imageRetriever = TestImageRetriever(result: .fail)

        imageView.gravatar.activityIndicatorType = .custom(activityIndicator)
        imageView.gravatar.setImage(email: "hello@gmail.com",
                                    options: [.imageDownloader(imageRetriever)]) { result in
            XCTAssertFalse(activityIndicator.animating)
            expectation.fulfill()
        }
        imageRetriever.sendNextResponse()
        wait(for: [expectation], timeout: 2.0)
    }
    
    func testIfPlaceholderIsSet() throws {
        let expectation = XCTestExpectation(description: "testIfPlaceholderIsSet")

        let imageView = UIImageView(frame: frame)
        let imageRetriever = TestImageRetriever(result: .fail)

        imageView.gravatar.setImage(email: "hello@gmail.com",
                                    placeholder: ImageHelper.placeholderImage,
                                    options: [.imageDownloader(imageRetriever)]) { result in
            XCTAssertNotNil(imageView.gravatar.placeholder)
            expectation.fulfill()
        }
        imageRetriever.sendNextResponse()
        wait(for: [expectation], timeout: 2.0)
    }
    
    func testIfPlaceholderIsSetWithNilURL() throws {
        let expectation = XCTestExpectation(description: "testIfPlaceholderIsSetWithNilURL")

        let imageView = UIImageView(frame: frame)
        let imageRetriever = TestImageRetriever(result: .fail)
        
        imageView.gravatar.setImage(with: nil,
                                    placeholder: ImageHelper.placeholderImage,
                                    options: [.imageDownloader(imageRetriever)]) { result in
            XCTAssertNotNil(imageView.gravatar.placeholder)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 2.0)
    }

    func testCancelOngoingDownload() throws {
        let imageView = UIImageView(frame: frame)
        let imageRetriever = TestImageRetriever(result: .success)
        
        imageView.gravatar.setImage(email: "hello@gmail.com",
                                    options: [.imageDownloader(imageRetriever)])

        let task = try XCTUnwrap(imageView.gravatar.downloadTask as? TestDataTask)
        
        imageView.gravatar.cancelImageDownload()
                
        XCTAssertTrue(task.cancelled)
    }
    
    func testRemoveCurrentImageWhileLoadingNoPlaceholder() throws {
        let imageView = UIImageView(frame: frame)
        imageView.image = ImageHelper.testImage
        let imageRetriever = TestImageRetriever(result: .success)
        
        imageView.gravatar.setImage(email: "hello@gmail.com",
                                    options: [.imageDownloader(imageRetriever),
                                              .removeCurrentImageWhileLoading])
        XCTAssertNil(imageView.image)
    }
    
    func testRemoveCurrentImageWhileLoadingWithPlaceholder() throws {
        let imageView = UIImageView(frame: frame)
        imageView.image = ImageHelper.testImage
        let imageRetriever = TestImageRetriever(result: .success)
        let placeholder = ImageHelper.placeholderImage
        
        imageView.gravatar.setImage(email: "hello@gmail.com",
                                    placeholder: placeholder,
                                    options: [.imageDownloader(imageRetriever),
                                              .removeCurrentImageWhileLoading])
        XCTAssertEqual(imageView.image, placeholder)
        XCTAssertEqual(imageView.gravatar.placeholder, placeholder)
    }

    
    func testNotCurrentSourceTaskResult() throws {
        let expectation = XCTestExpectation(description: "testNotCurrentSourceTaskResult")

        let imageView = UIImageView(frame: frame)
        let imageRetriever = TestImageRetriever(result: .success)
        
        let group = DispatchGroup()
        
        group.enter()
        // Pass .noResponse to simulate long lasting task
        imageView.gravatar.setImage(with: URL(string: "https://first.com"),
                                    options: [.imageDownloader(imageRetriever)]) { result in
            switch result {
            case .success:
                XCTFail()
            case .failure(let error):
                switch error {
                case .imageSettingError(let reason):
                    switch reason {
                    case .emptyURL:
                        XCTFail()
                    case let .outdatedTask(result, _, source):
                        XCTAssertEqual(source.absoluteString, "https://first.com")
                        XCTAssertNotNil(result?.image) // We got the image for "http://first.com"
                        break
                    }
                default:
                    XCTFail()
                }
            }
            group.leave()
        }

        group.enter()
        // Start a new task before the previous one completes
        imageView.gravatar.setImage(with: URL(string: "https://second.com"),
                                    options: [.imageDownloader(imageRetriever)]) { result in
            switch result {
            case .success(let value):
                XCTAssertEqual(value.sourceURL.absoluteString, "https://second.com")
            case .failure:
                XCTFail()
            }
            group.leave()
        }
        
        imageRetriever.sendResponse(for: "https://second.com")
        imageRetriever.sendResponse(for: "https://first.com")

        group.notify(queue: .main, execute: expectation.fulfill)
        wait(for: [expectation], timeout: 2.0)
    }
}
