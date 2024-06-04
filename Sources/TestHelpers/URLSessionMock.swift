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
    private(set) var isCancellable: Bool = false
    private(set) var maxDurationSeconds: Double = 2
    private(set) var callsCount = 0
    private(set) var request: URLRequest? = nil
    private(set) var uploadData: Data? = nil

    init(returnData: Data, response: HTTPURLResponse, error: NSError? = nil) {
        self.returnData = returnData
        self.response = response
        self.error = error
    }

    nonisolated func dataTask(with request: URLRequest, completionHandler: @escaping @Sendable (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        fatalError()
    }

    func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        callsCount += 1
        self.request = request
        if isCancellable {
            for i in 0 ... 100 {
                let durationSeconds = 0.05
                if Double(i) * durationSeconds > maxDurationSeconds {
                    break
                }
                try await Task.sleep(nanoseconds: UInt64(durationSeconds * 1_000_000_000))
                try Task.checkCancellation()
            }
        }
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

    func update(request: URLRequest) async {
        self.request = request
    }

    func update(isCancellable: Bool) async {
        self.isCancellable = isCancellable
    }

    func update(maxDurationSeconds: Double) async {
        self.maxDurationSeconds = maxDurationSeconds
    }
}
