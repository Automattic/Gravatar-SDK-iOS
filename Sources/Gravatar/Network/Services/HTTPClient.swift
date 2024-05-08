import Foundation
import OpenAPIRuntime
import HTTPTypes

/// A `HTTPClient` is used to perform basic networking operations.
///
/// You can provide your own type conforming to this protocol to gain control over all networking operations performed internally by this SDK.
/// For more info, see ``AvatarService/init(client:cache:)`` and ``ProfileService/init(client:)``.
public protocol InternalHTTPClient: Sendable {
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
}

// NOTE: No changes on external Clients, BUT `ClientTransport` will become public for this to work.
// (InternalHTTPClient also but we can find a better name)
// I'd prefer to not generate the client automatically, but this is big part of the idea of OpenApi.
public protocol HTTPClient: InternalHTTPClient & ClientTransport {

}

extension HTTPClient {
    func send(_ request: HTTPTypes.HTTPRequest, body: OpenAPIRuntime.HTTPBody?, baseURL: URL, operationID: String) async throws -> (HTTPTypes.HTTPResponse, OpenAPIRuntime.HTTPBody?) {
        let req = try URLRequest(request, baseURL: baseURL)

        let (data, response) = try await fetchData(with: req)

        return (try HTTPResponse(response), .init(data))
    }
}


// MARK: - Helper inits

extension URLRequest {
    init(_ request: HTTPRequest, baseURL: URL) throws {
        guard var baseUrlComponents = URLComponents(string: baseURL.absoluteString),
              let requestUrlComponents = URLComponents(string: request.path ?? "")
        else {
            throw ProfileServiceError.requestError(reason: .urlInitializationFailed)
        }

        let path = requestUrlComponents.percentEncodedPath
        baseUrlComponents.percentEncodedPath += path
        baseUrlComponents.percentEncodedQuery = requestUrlComponents.percentEncodedQuery
        guard let url = baseUrlComponents.url else {
            throw ProfileServiceError.requestError(reason: .urlInitializationFailed)
        }
        self.init(url: url)
        self.httpMethod = request.method.rawValue
        for header in request.headerFields { setValue(header.value, forHTTPHeaderField: header.name.canonicalName) }
    }
}

extension HTTPResponse {
    init(_ urlResponse: URLResponse) throws {
        guard let httpResponse = urlResponse as? HTTPURLResponse else {
            throw ProfileServiceError.noProfileInResponse
        }
        var headerFields = HTTPFields()
        for (headerName, headerValue) in httpResponse.allHeaderFields {
            guard let rawName = headerName as? String, let name = HTTPField.Name(rawName),
                  let value = headerValue as? String
            else { continue }
            headerFields[name] = value
        }
        self.init(status: .init(code: httpResponse.statusCode), headerFields: headerFields)
    }
}

