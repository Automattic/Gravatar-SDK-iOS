import Foundation
import Gravatar

public class URLSessionMock: URLSessionProtocol {
    public static let jsonData = """
    {
        "name": "John",
        "surname": "Appleseed"
    }
    """.data(using: .utf8)!

    public let returnData: Data
    public let response: HTTPURLResponse
    public let error: NSError?
    public var callsCount = 0

    public var request: URLRequest? = nil
    public var uploadData: Data? = nil

    public init(returnData: Data, response: HTTPURLResponse, error: NSError? = nil) {
        self.returnData = returnData
        self.response = response
        self.error = error
    }

    public func dataTask(with request: URLRequest, completionHandler: @escaping @Sendable (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        fatalError()
    }

    public func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        callsCount += 1
        self.request = request
        if let error {
            throw error
        }
        return (returnData, response)
    }

    public func upload(for request: URLRequest, from bodyData: Data) async throws -> (Data, URLResponse) {
        self.request = request
        self.uploadData = bodyData
        if let error {
            throw error
        }
        return (returnData, response)
    }
}
