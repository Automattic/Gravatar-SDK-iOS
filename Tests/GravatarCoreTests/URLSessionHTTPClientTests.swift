@testable import GravatarCore
import XCTest

final class URLSessionHTTPClientTests: XCTestCase {
    func testFetchReturnsData() async throws {
        let sessionMock = URLSessionMock(returnData: jsonData, response: HTTPURLResponse())
        let client = URLSessionHTTPClient(urlSession: sessionMock)
        let mockUrlRequest = URLRequest(url: URL(string: "https://a-host.com")!)
        let result: (data: Data, response: HTTPURLResponse) = try await client.fetchData(with: mockUrlRequest)

        XCTAssertEqual(result.data, jsonData)
    }

    func testFetchReturnsError() async throws {
        let anError = NSError(domain: NSURLErrorDomain, code: 400)
        let sessionMock = URLSessionMock(
            returnData: "".data(using: .utf8)!,
            response: HTTPURLResponse(),
            error: anError
        )
        let client = URLSessionHTTPClient(urlSession: sessionMock)
        let mockUrlRequest = URLRequest(url: URL(string: "https://a-host.com")!)

        do {
            let _ = try await client.fetchData(with: mockUrlRequest)
            XCTFail("This should throw")
        } catch HTTPClientError.URLSessionError(let error) {
            XCTAssertEqual((error as NSError).code, 400)
        } catch {
            XCTFail()
        }
    }

    func testFetchWithInvalidStatusCodeError() async throws {
        let invalidStatusCodes = [400, 401, 402, 403, 404, 500, 501, 502, 599]

        for invalidStatusCode in invalidStatusCodes {
            let response = HTTPURLResponse(url: URL(string: "https://a-host.com")!, statusCode: invalidStatusCode, httpVersion: nil, headerFields: nil)!
            let sessionMock = URLSessionMock(returnData: "Error happened".data(using: .utf8)!, response: response)
            let client = URLSessionHTTPClient(urlSession: sessionMock)
            let mockUrlRequest = URLRequest(url: URL(string: "https://a-host.com")!)

            do {
                let _ = try await client.fetchData(with: mockUrlRequest)
                XCTFail("This should throw")
            } catch HTTPClientError.invalidHTTPStatusCodeError(let response) {
                XCTAssertEqual(response.statusCode, invalidStatusCode)
            } catch {
                XCTFail()
            }
        }
    }

    func testFetchWithValidStatusCode() async throws {
        let validStatusCodes = [199, 200, 201, 304]
        let url = URL(string: "https://a-host.com")!
        for validStatusCode in validStatusCodes {
            let response = HTTPURLResponse(
                url: url,
                statusCode: validStatusCode,
                httpVersion: nil,
                headerFields: nil
            )!
            let sessionMock = URLSessionMock(returnData: "Error happened".data(using: .utf8)!, response: response)
            let client = URLSessionHTTPClient(urlSession: sessionMock)
            let mockUrlRequest = URLRequest(url: url)

            let result: (data: Data, response: HTTPURLResponse) = try await client.fetchData(with: mockUrlRequest)

            XCTAssertEqual(result.response.statusCode, validStatusCode)
        }
    }
}

private let jsonData = """
{
    "name": "John",
    "surname": "Appleseed"
}
""".data(using: .utf8)!

class URLSessionMock: URLSessionProtocol {
    let returnData: Data
    let response: HTTPURLResponse
    let error: NSError?
    var callsCount = 0

    var request: URLRequest? = nil
    var uploadData: Data? = nil

    init(returnData: Data, response: HTTPURLResponse, error: NSError? = nil) {
        self.returnData = returnData
        self.response = response
        self.error = error
    }

    func dataTask(with request: URLRequest, completionHandler: @escaping @Sendable (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        fatalError()
    }

    func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        callsCount += 1
        self.request = request
        if let error {
            throw error
        }
        return (returnData, response)
    }

    func upload(for request: URLRequest, from bodyData: Data) async throws -> (Data, URLResponse) {
        self.request = request
        self.uploadData = bodyData
        if let error {
            throw error
        }
        return (returnData, response)
    }
}
