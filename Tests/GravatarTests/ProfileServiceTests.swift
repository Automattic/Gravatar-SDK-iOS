@testable import Gravatar
import XCTest

final class ProfileServiceTests: XCTestCase {
    override func tearDown() async throws {
        await Configuration.shared.configure(with: nil)
    }

    func testProfileRequest() async {
        guard let data = Bundle.fullProfileJsonData else {
            return XCTFail("Could not create data")
        }
        let session = URLSessionMock(returnData: data, response: .successResponse())
        let service = ProfileService(client: HTTPClientMock(session: session))

        do {
            _ = try await service.fetch(with: .hashID(""))
            XCTAssertNil(session.request?.value(forHTTPHeaderField: "Authorization"))
        } catch {
            XCTFail(error.localizedDescription)
        }
    }

    func testProfileRequestWithApiKey() async {
        guard let data = Bundle.fullProfileJsonData else {
            return XCTFail("Could not create data")
        }

        await Configuration.shared.configure(with: "somekey")

        let session = URLSessionMock(returnData: data, response: .successResponse())
        let service = ProfileService(client: HTTPClientMock(session: session))

        do {
            _ = try await service.fetch(with: .hashID(""))
            XCTAssertNotNil(session.request?.value(forHTTPHeaderField: "Authorization"))
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
}

extension Bundle {
    func jsonData(forResource resource: String) -> Data? {
        guard let url = Bundle.testsBundle.url(forResource: resource, withExtension: "json") else {
            return nil
        }
        return try? Data(contentsOf: url)
    }

    static var fullProfileJsonData: Data? {
        testsBundle.jsonData(forResource: "fullProfile")
    }
}
