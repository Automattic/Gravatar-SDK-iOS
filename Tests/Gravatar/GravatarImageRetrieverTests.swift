//
//  GravatarImageRetrieverTests.swift
//  
//
//  Created by Pinar Olguc on 24.01.2024.
//

import XCTest
import UIKit
@testable import Gravatar

final class GravatarImageRetrieverTests: XCTestCase {

    func testForceRefreshEnabled() throws {
        let expectation = XCTestExpectation(description: "testForceRefreshEnabled")

        let cache = TestImageCache()
        let urlSession = TestURLSession()
        let imageRetriever = GravatarImageRetriever(imageCache: cache, urlSession: urlSession)
        
        imageRetriever.retrieveImage(with: "pinar@gmail.com",
                                     options: .init(forceRefresh: true)) { result in

            XCTAssertEqual(cache.getImageCallCount, 0, "We should not hit the cache")
            XCTAssertEqual(urlSession.dataTaskCount, 1, "We should fetch from network")
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 2.0)
    }
    
    func testForceRefreshDisabled() throws {
        let expectation = XCTestExpectation(description: "testForceRefreshDisabled")

        let cache = TestImageCache()
        let urlSession = TestURLSession()
        let imageRetriever = GravatarImageRetriever(imageCache: cache, urlSession: urlSession)
        
        imageRetriever.retrieveImage(with: "pinar@gmail.com",
                                     options: .init(forceRefresh: false)) { result in

            XCTAssertEqual(cache.getImageCallCount, 1, "We should hit the cache")
            XCTAssertEqual(urlSession.dataTaskCount, 1, "We fetch from network because the cache is empty")

            // try again
            imageRetriever.retrieveImage(with: "pinar@gmail.com",
                                         options: .init(forceRefresh: false)) { result in

                XCTAssertEqual(cache.getImageCallCount, 2, "We should hit the cache")
                XCTAssertEqual(urlSession.dataTaskCount, 1, "This time we don't fetch from network because we return the cached image")
                expectation.fulfill()
            }
        }
        wait(for: [expectation], timeout: 2.0)
    }
    
    func testEmptyDataReturned() throws {
        let expectation = XCTestExpectation(description: "testEmptyDataReturned")

        let cache = TestImageCache()
        let urlSession = TestURLSession(failReason: .dataEmpty)
        let imageRetriever = GravatarImageRetriever(imageCache: cache, urlSession: urlSession)
        
        imageRetriever.retrieveImage(with: "pinar@gmail.com") { result in
            switch result {
            case .success:
                XCTAssert(false)
            case .failure(let error):
                XCTAssertEqual(error, GravatarImageDownloadError.responseError(reason: .imageInitializationFailed))
                expectation.fulfill()
            }
        }
        wait(for: [expectation], timeout: 2.0)
    }
    
    func testAvatarNotFound() throws {
        let expectation = XCTestExpectation(description: "testAvatarNotFound")

        let cache = TestImageCache()
        let urlSession = TestURLSession(failReason: .notFound)
        let imageRetriever = GravatarImageRetriever(imageCache: cache, urlSession: urlSession)
        
        imageRetriever.retrieveImage(with: "pinar@gmail.com") { result in
            switch result {
            case .success:
                XCTAssert(false)
            case .failure(let error):
                XCTAssertEqual(error, GravatarImageDownloadError.responseError(reason: .notFound))
                expectation.fulfill()
            }
        }
        wait(for: [expectation], timeout: 2.0)
    }
    
    func testURLMismatch() throws {
        let expectation = XCTestExpectation(description: "testURLMismatch")

        let cache = TestImageCache()
        let urlSession = TestURLSession(failReason: .urlMismatch)
        let imageRetriever = GravatarImageRetriever(imageCache: cache, urlSession: urlSession)
        
        imageRetriever.retrieveImage(with: "pinar@gmail.com") { result in
            switch result {
            case .success:
                XCTAssert(false)
            case .failure(let error):
                XCTAssertEqual(error, GravatarImageDownloadError.responseError(reason: .urlMismatch))
                expectation.fulfill()
            }
        }
        wait(for: [expectation], timeout: 2.0)
    }
    
    func testURLSessionError() throws {
        let expectation = XCTestExpectation(description: "testURLSessionError")

        let cache = TestImageCache()
        let urlSession = TestURLSession(failReason: .urlSessionError)
        let imageRetriever = GravatarImageRetriever(imageCache: cache, urlSession: urlSession)
        
        imageRetriever.retrieveImage(with: "pinar@gmail.com") { result in
            switch result {
            case .success:
                XCTAssert(false)
            case .failure(let error):
                XCTAssertEqual(error, GravatarImageDownloadError.responseError(reason: .URLSessionError(error: TestURLSession.error)))
                expectation.fulfill()
            }
        }
        wait(for: [expectation], timeout: 2.0)
    }
    
    func testSuccessfulFetch() throws {
        let expectation = XCTestExpectation(description: "testSuccessfulFetch")

        let cache = TestImageCache()
        let urlSession = TestURLSession()
        let imageRetriever = GravatarImageRetriever(imageCache: cache, urlSession: urlSession)
        
        imageRetriever.retrieveImage(with: "pinar@gmail.com",
                                     options: .init(forceRefresh: true)) { result in
            switch result {
            case .success(let value):
                XCTAssertEqual(value.image.size, CGSize(width: 75, height: 75))
            case .failure:
                XCTAssert(false, "An image should be fetched")
            }

            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 2.0)
    }
    
    func testEmptyURL() throws {
        let expectation = XCTestExpectation(description: "testEmptyURL")

        let cache = TestImageCache()
        let urlSession = TestURLSession()
        let imageRetriever = GravatarImageRetriever(imageCache: cache, urlSession: urlSession)
        var request = URLRequest(url: URL(string: "https://hello.com")!)
        request.url = nil
        imageRetriever.retrieveImage(with: request) { result in
            switch result {
            case .success:
                XCTAssert(false)
            case .failure(let error):
                XCTAssertEqual(error, GravatarImageDownloadError.requestError(reason: .emptyURL))
            }

            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 2.0)
    }
}
