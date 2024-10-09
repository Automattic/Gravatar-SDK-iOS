import Foundation
import Gravatar

package actor URLSessionMock: URLSessionProtocol {
    package static let jsonData = """
    {
        "name": "John",
        "surname": "Appleseed"
    }
    """.data(using: .utf8)!

    let returnData: Data
    let response: HTTPURLResponse
    private(set) var error: NSError?
    private(set) var isCancellable: Bool = false
    private(set) var maxDurationSeconds: Double = 2
    package private(set) var callsCount = 0
    package private(set) var request: URLRequest? = nil
    package private(set) var uploadData: Data? = nil

    package init(returnData: Data, response: HTTPURLResponse, error: NSError? = nil) {
        self.returnData = returnData
        self.response = response
        self.error = error
    }

    package nonisolated func dataTask(
        with request: URLRequest,
        completionHandler: @escaping @Sendable (Data?, URLResponse?, Error?) -> Void
    ) -> URLSessionDataTask {
        fatalError()
    }

    package func data(for request: URLRequest) async throws -> (Data, URLResponse) {
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

    package func upload(for request: URLRequest, from bodyData: Data) async throws -> (Data, URLResponse) {
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

    package func update(error: NSError?) async {
        self.error = error
    }

    package func update(isCancellable: Bool) async {
        self.isCancellable = isCancellable
    }

    package func update(maxDurationSeconds: Double) async {
        self.maxDurationSeconds = maxDurationSeconds
    }
}
