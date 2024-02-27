@testable import Gravatar
import XCTest

final class ProfileServiceTests: XCTestCase {
    func testFetchGravatarProfile() async throws {
        let session = URLSessionMock(returnData: jsonData, response: .successResponse())
        let client = URLSessionHTTPClient(urlSession: session)
        let service = ProfileService(client: client)
        let profile = try await service.fetchProfile(for: "some@email.com")

        XCTAssertEqual(profile.displayName, "Beau Lebens")
    }

    func testFetchGravatarProfileError() async throws {
        let session = URLSessionMock(returnData: jsonData, response: .errorResponse(code: 404))
        let client = URLSessionHTTPClient(urlSession: session)
        let service = ProfileService(client: client)

        do {
            _ = try await service.fetchProfile(for: "some@email.com")
        } catch ProfileServiceError.responseError(reason: let reason) {
            XCTAssertEqual(reason.httpStatusCode, 404)
        } catch {
            XCTFail()
        }
    }

    func testFetchGravatarProfileWithCompletionHandler() {
        let session = URLSessionMock(returnData: jsonData, response: .successResponse())
        let client = URLSessionHTTPClient(urlSession: session)
        let service = ProfileService(client: client)
        let expectation = expectation(description: "request finishes")

        service.fetchProfile(with: "some@email.com") { result in
            switch result {
            case .success(let profile):
                XCTAssertEqual(profile.displayName, "Beau Lebens")
            case .failure(let error):
                XCTFail(error.localizedDescription)
            }
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 0.1)
    }

    func testFetchGravatarProfileWithCompletionHandlerError() {
        let session = URLSessionMock(returnData: jsonData, response: .errorResponse(code: 404))
        let client = URLSessionHTTPClient(urlSession: session)
        let service = ProfileService(client: client)
        let expectation = expectation(description: "request finishes")

        service.fetchProfile(with: "some@email.com") { result in
            switch result {
            case .success:
                XCTFail("Should error")
            case .failure(.responseError(let reason)):
                XCTAssertEqual(reason.httpStatusCode, 404)
            default:
                XCTFail()
            }
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 0.1)
    }
}

private let jsonData = """
{
    "entry": [
        {
            "hash": "22bd03ace6f176bfe0c593650bcf45d8",
            "requestHash": "205e460b479e2e5b48aec07710c08d50",
            "profileUrl": "https://gravatar.com/beau",
            "preferredUsername": "beau",
            "thumbnailUrl": "https://0.gravatar.com/avatar/22bd03ace6f176bfe0c593650bcf45d8",
            "photos": [
                {
                    "value": "https://0.gravatar.com/avatar/22bd03ace6f176bfe0c593650bcf45d8",
                    "type": "thumbnail"
                }
            ],
            "last_profile_edit": "2023-12-01 20:25:10",
            "profileBackground": {
                "color": "#f9ce37",
                "url": "https://2.gravatar.com/bg/1428/4f6eae389c98bf908c7cb50ccd03e7af"
            },
            "name": {
                "givenName": "Beau",
                "familyName": "Lebens",
                "formatted": "Beau Lebens"
            },
            "displayName": "Beau Lebens",
            "pronouns": "he/him",
            "aboutMe": "Head of Engineering for WooCommerce, at Automattic. Previously Jetpack, WordPress.com and more. I've been building the web for over 20 years.",
            "currentLocation": "Golden, CO",
            "contactInfo": [
                {
                    "type": "contactform",
                    "value": "https://beau.blog/about"
                }
            ],
            "emails": [
                {
                    "primary": "true",
                    "value": "beau@automattic.com"
                }
            ],
            "urls": [

            ],
            "share_flags": {
                "search_engines": true
            }
        }
    ]
}
""".data(using: .utf8)!
