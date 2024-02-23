import XCTest
@testable import Gravatar

final class URLSessionHTTPClientTests: XCTestCase {
    func testFetchObject() async throws {
        let sessionMock = URLSessionMock(returnData: jsonData, response: HTTPURLResponse())
        let remote = URLSessionHTTPClient(urlSession: sessionMock)
        let testObject: TestObject = try await remote.fetchObject(from: "name")

        XCTAssertEqual(sessionMock.request?.url?.absoluteString, "https://gravatar.com/name")
        XCTAssertEqual(testObject.name, "John")
        XCTAssertEqual(testObject.surname, "Appleseed")
    }

    func testFetchObjectError() async throws {
        let anError = NSError(domain: NSURLErrorDomain, code: 400)
        let sessionMock = URLSessionMock(returnData: "".data(using: .utf8)!, response: HTTPURLResponse(), error: anError)
        let remote = URLSessionHTTPClient(urlSession: sessionMock)

        do {
            let _: TestObject = try await remote.fetchObject(from: "name")
            XCTFail("This should throw")
        } catch HTTPClientError.URLSessionError(let error) {
            XCTAssertEqual((error as NSError).code, 400)
        } catch {
            XCTFail()
        }
    }

    func testFetchObjectErrorWithoutErrorObject() async throws {
        let response = HTTPURLResponse(url: URL(string: "https://gravatar.com")!, statusCode: 404, httpVersion: nil, headerFields: nil)!
        let sessionMock = URLSessionMock(returnData: "Error happened".data(using: .utf8)!, response: response)
        let remote = URLSessionHTTPClient(urlSession: sessionMock)

        do {
            let _: TestObject = try await remote.fetchObject(from: "name")
            XCTFail("This should throw")
        } catch HTTPClientError.invalidHTTPStatusCodeError(let response) {
            XCTAssertEqual(response.statusCode, 404)
        } catch {
            XCTFail()
        }
    }
}

private struct TestObject: Decodable {
    let name: String
    let surname: String
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
        if let error = error {
            throw error
        }
        return (returnData, response)
    }

    func upload(for request: URLRequest, from bodyData: Data) async throws -> (Data, URLResponse) {
        self.request = request
        self.uploadData = bodyData
        if let error = error {
            throw error
        }
        return (returnData, response)
    }
}
