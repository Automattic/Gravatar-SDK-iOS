import Foundation

public protocol HTTPClient {
    func fetchData(with request: URLRequest) async throws -> (Data, URLResponse)
    func uploadData(with request: URLRequest, data: Data) async throws -> URLResponse
    func fetchObject<T: Decodable>(from path: String) async throws -> T
}
