//
//  TestURLSession.swift
//
//
//  Created by Pinar Olguc on 24.01.2024.
//

import Foundation
import Gravatar
import XCTest

enum TestDataTaskFailReason: Equatable {
    case dataEmpty
    case urlSessionError
    case notFound
    case urlMismatch
}

class TestURLSession: URLSessionProtocol {
    func upload(for request: URLRequest, from bodyData: Data) async throws -> (Data, URLResponse) {
        XCTFail("Not implemented")
        fatalError()
    }

    func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        XCTFail("Not implemented")
        fatalError()
    }

    var failReason: TestDataTaskFailReason?
    private(set) var dataTaskCount: Int = 0
    static let error = NSError(domain: "test", code: 1234)

    init(failReason: TestDataTaskFailReason? = nil) {
        self.failReason = failReason
    }

    func dataTask(with request: URLRequest, completionHandler: @escaping @Sendable (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        dataTaskCount += 1
        guard let url = request.url else {
            XCTFail()
            return URLSession.shared.dataTask(with: request)
        }
        guard let failReason else {
            let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)
            completionHandler(ImageHelper.testImageData, response, nil)
            return URLSession.shared.dataTask(with: request)
        }
        switch failReason {
        case .dataEmpty:
            let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)
            completionHandler(nil, response, nil)
            return URLSession.shared.dataTask(with: request)
        case .notFound:
            let response = HTTPURLResponse(url: url, statusCode: 404, httpVersion: nil, headerFields: nil)
            completionHandler(nil, response, nil)
            return URLSession.shared.dataTask(with: request)
        case .urlMismatch:
            let response = HTTPURLResponse(url: URL(string: "https://test.com")!, statusCode: 200, httpVersion: nil, headerFields: nil)
            completionHandler(ImageHelper.testImageData, response, nil)
            return URLSession.shared.dataTask(with: request)
        case .urlSessionError:
            completionHandler(nil, nil, TestURLSession.error)
            return URLSession.shared.dataTask(with: request)
        }
    }
}

extension GravatarImageDownloadError: Equatable {
    public static func == (lhs: GravatarImageDownloadError, rhs: GravatarImageDownloadError) -> Bool {
        switch (lhs, rhs) {
        case (.requestError(let reason1), .requestError(let reason2)):
            reason1 == reason2
        case (.responseError(let reason1), .responseError(let reason2)):
            reason1 == reason2
        default:
            false
        }
    }
}

extension GravatarImageDownload.ResponseErrorReason: Equatable {
    public static func == (lhs: GravatarImageDownload.ResponseErrorReason, rhs: GravatarImageDownload.ResponseErrorReason) -> Bool {
        switch (lhs, rhs) {
        case (.imageInitializationFailed, .imageInitializationFailed):
            return true
        case (.notFound, .notFound):
            return true
        case (.urlMismatch, .urlMismatch):
            return true
        case (.urlMissingInResponse, .urlMissingInResponse):
            return true
        case (.URLSessionError(let error1), .URLSessionError(let error2)):
            let error1 = error1 as NSError
            let error2 = error2 as NSError
            return error1.domain == error2.domain && error1.code == error2.code
        default:
            return false
        }
    }
}
