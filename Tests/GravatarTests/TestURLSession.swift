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

extension ImageFetchingError: Equatable {
    public static func == (lhs: ImageFetchingError, rhs: ImageFetchingError) -> Bool {
        switch (lhs, rhs) {
        case (.requestError(let reason1), .requestError(let reason2)):
            return reason1 == reason2
        case (.responseError(let reason1), .responseError(let reason2)):
            return reason1 == reason2
        case (.imageInitializationFailed, .imageInitializationFailed):
            return true
        default:
            return false
        }
    }
}

extension ResponseErrorReason: Equatable {
    
    public static func == (lhs: ResponseErrorReason, rhs: ResponseErrorReason) -> Bool {
        switch (lhs, rhs) {
        case (.invalidHTTPStatusCode(let response1), .invalidHTTPStatusCode(let response2)):
            return response1.statusCode == response2.statusCode
        case (.URLSessionError, .URLSessionError):
            return true
        case (.unexpected, .unexpected):
            return true
        case (.invalidURLResponse, .invalidURLResponse):
            return true
        default:
            return false
        }
    }
}

extension ImageUploadError: Equatable {
    public static func == (lhs: ImageUploadError, rhs: ImageUploadError) -> Bool {
        switch (lhs, rhs) {
        case (.responseError(let reason1), .responseError(let reason2)):
            return reason1 == reason2
        case (.cannotConvertImageIntoData, .cannotConvertImageIntoData):
            return true
        default:
            return false
        }
    }
}
