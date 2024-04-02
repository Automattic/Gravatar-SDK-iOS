import Foundation
import Gravatar

class URLSessionMock: URLSessionProtocol {
    static let jsonData = """
    {
        "name": "John",
        "surname": "Appleseed"
    }
    """.data(using: .utf8)!

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
