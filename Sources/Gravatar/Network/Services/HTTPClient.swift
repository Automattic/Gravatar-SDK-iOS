import Foundation

public protocol HTTPClient {
    func fetchData(with request: URLRequest) async throws -> (Data, HTTPURLResponse)
    func uploadData(with request: URLRequest, data: Data) async throws -> HTTPURLResponse
}
