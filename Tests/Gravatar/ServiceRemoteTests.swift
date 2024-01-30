import XCTest
@testable import Gravatar

final class ServiceRemoteTests: XCTestCase {
    func testFetchObject() async throws {
        let sessionMock = URLSessionMock(returnData: jsonData, response: HTTPURLResponse())
        let remote = ServiceRemote(urlSession: sessionMock)
        let testObject: TestObject = try await remote.fetchObject(from: "name")

        XCTAssertEqual(sessionMock.request?.url?.absoluteString, "https://gravatar.com/name")
        XCTAssertEqual(testObject.name, "John")
        XCTAssertEqual(testObject.surname, "Appleseed")
    }

    func testFetchObjectError() async throws {
        let anError = NSError(domain: NSURLErrorDomain, code: 400)
        let sessionMock = URLSessionMock(returnData: "".data(using: .utf8)!, response: HTTPURLResponse(), error: anError)
        let remote = ServiceRemote(urlSession: sessionMock)

        do {
            let _: TestObject = try await remote.fetchObject(from: "name")
            XCTFail("This should throw")
        } catch {
            XCTAssertEqual((error as NSError).code, 400)
        }
    }

    func testFetchObjectErrorWithoutErrorObject() async throws {
        let response = HTTPURLResponse(url: URL(string: "https://gravatar.com")!, statusCode: 404, httpVersion: nil, headerFields: nil)!
        let sessionMock = URLSessionMock(returnData: "Error happened".data(using: .utf8)!, response: response)
        let remote = ServiceRemote(urlSession: sessionMock)

        do {
            let _: TestObject = try await remote.fetchObject(from: "name")
            XCTFail("This should throw")
        } catch {
            XCTAssertEqual((error as NSError).code, 404)
            XCTAssertEqual((error as NSError).localizedDescription, "not found")
        }
    }

    func testForceRefreshEnabled() async throws {
        let cache = TestImageCache()
        let urlSession = URLSessionMock(returnData: ImageHelper.testImageData, response: HTTPURLResponse.successResponse(with: URL(string: "https://gravatar.com")))
        let service = ImageService(urlSession: urlSession, cache: cache)
        let options = GravatarImageDownloadOptions(forceRefresh: true)

        _ = try await service.fetchImage(with: "some@email.com", options: options)
        _ = try await service.fetchImage(with: "some@email.com", options: options)
        _ = try await service.fetchImage(with: "some@email.com", options: options)

        XCTAssertEqual(cache.getImageCallCount, 0, "We should not hit the cache")
        XCTAssertEqual(urlSession.callsCount, 3, "We should fetch from network")
    }

    func testForceRefreshDisabled() async throws {
        let cache = TestImageCache()
        let urlSession = URLSessionMock(returnData: ImageHelper.testImageData, response: HTTPURLResponse.successResponse(with: URL(string: "https://gravatar.com")))
        let service = ImageService(urlSession: urlSession, cache: cache)
        let options = GravatarImageDownloadOptions(forceRefresh: false)

        _ = try await service.fetchImage(with: "some@email.com", options: options)
        _ = try await service.fetchImage(with: "some@email.com", options: options)
        _ = try await service.fetchImage(with: "some@email.com", options: options)

        XCTAssertEqual(cache.getImageCallCount, 3, "We should hit the cache")
        XCTAssertEqual(cache.setImageCallsCount, 1, "We should save once to the cache")
        XCTAssertEqual(urlSession.callsCount, 1, "We should fetch from network only the first time")
    }
}

private struct TestObject: Decodable {
    let name: String
    let surname: String
}

let jsonData = """
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
