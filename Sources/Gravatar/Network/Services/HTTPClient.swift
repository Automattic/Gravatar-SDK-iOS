import Foundation

/// A `HTTPClient` is used to perform basic networking operations.
///
/// You can provide your own type conforming to this protocol to gain control over all networking operations performed internally by this SDK.
/// For more info, see ``ImageService/init(client:cache:)`` and ``ProfileService/init(client:)``.
public protocol HTTPClient {

    /// Performs a data request using the  information provided,  and delivers the result asynchronously.
    /// - Parameter request: A URL request object that provides request-specific information such as the URL and cache policy.
    /// - Returns: An asynchronously-delivered tuple that contains the URL contents as a Data instance, and a HTTPURLResponse.
    func fetchData(with request: URLRequest) async throws -> (Data, HTTPURLResponse)

    /// Uploads data to a URL based on the specified URL request and delivers the result asynchronously.
    /// - Parameters:
    ///   - request: A URL request object that provides request-specific information such as the URL and cache policy.
    ///   - data: The data to be uploaded.
    /// - Returns: An asynchronously-delivered instance of the returned HTTPURLResponse.
    func uploadData(with request: URLRequest, data: Data) async throws -> HTTPURLResponse

    //TODO: document after change.
    func fetchObject<T: Decodable>(from path: String) async throws -> T
}
