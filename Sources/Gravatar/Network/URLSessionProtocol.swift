import UIKit

/// Protocol for dependency injection purposes. `URLSession` conforms to  this protocol.
public protocol URLSessionProtocol {
    func dataTask(
        with request: URLRequest,
        completionHandler: @escaping @Sendable (Data?, URLResponse?, Error?) -> Void
    ) -> URLSessionDataTask

    func data(for request: URLRequest)  async throws -> (Data, URLResponse)

    func upload(for request: URLRequest, from bodyData: Data) async throws -> (Data, URLResponse)
}

extension URLSession: URLSessionProtocol { 
    
}
