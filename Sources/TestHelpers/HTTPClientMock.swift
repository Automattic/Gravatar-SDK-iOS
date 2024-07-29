import Foundation
import Gravatar

package struct HTTPClientMock: HTTPClient {
    private let session: URLSessionMock

    package init(session: URLSessionMock) {
        self.session = session
    }

    package func fetchData(with request: URLRequest) async throws -> (Data, HTTPURLResponse) {
        await session.update(request: request)
        return (session.returnData, session.response)
    }

    package func uploadData(with request: URLRequest, data: Data) async throws -> HTTPURLResponse {
        session.response
    }
}
