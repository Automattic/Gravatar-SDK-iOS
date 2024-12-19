import Gravatar
import TestHelpers
import XCTest

final class ProfileServiceTests: XCTestCase {
    override func tearDown() async throws {
        await Configuration.shared.configure(with: nil)
    }

    func testProfileRequest() async {
        let data = Bundle.fullProfileJsonData
        let session = URLSessionMock(returnData: data, response: .successResponse())
        let service = ProfileService(urlSession: session)

        do {
            _ = try await service.fetch(with: .hashID(""))
            let request = await session.request
            XCTAssertNil(request?.value(forHTTPHeaderField: "Authorization"))
        } catch {
            XCTFail(error.localizedDescription)
        }
    }

    func testProfileRequestDecodingError() async {
        guard let data = "FaultyResponse".data(using: .utf8) else {
            return XCTFail("Could not create data")
        }
        let session = URLSessionMock(returnData: data, response: .successResponse())
        let service = ProfileService(urlSession: session)

        do {
            _ = try await service.fetch(with: .hashID(""))
            let _ = await session.request
            XCTFail()
        } catch APIError.decodingError {
            // Success
        } catch {
            XCTFail(error.localizedDescription)
        }
    }

    func testProfileRequestInvalidHTTPStatusError() async {
        let data = Bundle.fullProfileJsonData
        let session = URLSessionMock(returnData: data, response: .errorResponse(code: 404))
        let service = ProfileService(urlSession: session)

        do {
            let _ = try await service.fetch(with: .hashID(""))
            XCTFail()
        } catch APIError.responseError(reason: let reason) where reason.httpStatusCode == 404 {
            // Expected error has occurred.
        } catch {
            XCTFail(error.localizedDescription)
        }
    }

    func testProfileRequestWithApiKey() async {
        let data = Bundle.fullProfileJsonData

        await Configuration.shared.configure(with: "somekey")

        let session = URLSessionMock(returnData: data, response: .successResponse())
        let service = ProfileService(urlSession: session)

        do {
            _ = try await service.fetch(with: .hashID(""))
            let request = await session.request
            XCTAssertNotNil(request?.value(forHTTPHeaderField: "Authorization"))
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
}
