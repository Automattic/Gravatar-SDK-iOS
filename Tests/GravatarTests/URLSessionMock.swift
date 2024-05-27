import Foundation
import Gravatar

actor URLSessionMock: URLSessionProtocol {
    static let jsonData = """
    {
        "name": "John",
        "surname": "Appleseed"
    }
    """.data(using: .utf8)!

    let returnData: Data
    let response: HTTPURLResponse
    let error: NSError?
    private var _callsCount = 0
    var callsCount: Int {
        get async {
            _callsCount
        }
    }
    private var _request: URLRequest? = nil
    var request: URLRequest? {
        get async {
            _request
        }
    }
    private var _uploadData: Data? = nil
    var uploadData: Data? {
        get async {
            _uploadData
        }
    }
    
    init(returnData: Data, response: HTTPURLResponse, error: NSError? = nil) {
        self.returnData = returnData
        self.response = response
        self.error = error
    }

    nonisolated func dataTask(with request: URLRequest, completionHandler: @escaping @Sendable (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        fatalError()
    }

    func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        _callsCount += 1
        self._request = request
        if let error {
            throw error
        }
        return (returnData, response)
    }

    func upload(for request: URLRequest, from bodyData: Data) async throws -> (Data, URLResponse) {
        self._request = request
        self._uploadData = bodyData
        if let error {
            throw error
        }
        return (returnData, response)
    }
    
    func update(request: URLRequest) async {
        _request = request
    }
}
