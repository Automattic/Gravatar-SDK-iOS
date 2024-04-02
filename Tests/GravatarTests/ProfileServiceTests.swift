@testable import Gravatar
import TestHelpers
import XCTest

final class ProfileServiceTests: XCTestCase {
    func testFetchGravatarProfile() async throws {
        let session = URLSessionMock(returnData: jsonData, response: .successResponse())
        let client = URLSessionHTTPClient(urlSession: session)
        let service = ProfileService(client: client)
        let profile = try await service.fetch(with: .email("some@email.com"))

        XCTAssertEqual(profile.displayName, "Beau Lebens")
    }

    func testFetchGravatarProfileError() async throws {
        let session = URLSessionMock(returnData: jsonData, response: .errorResponse(code: 404))
        let client = URLSessionHTTPClient(urlSession: session)
        let service = ProfileService(client: client)

        do {
            _ = try await service.fetch(with: .email("some@email.com"))
        } catch ProfileServiceError.responseError(reason: let reason) {
            XCTAssertEqual(reason.httpStatusCode, 404)
        } catch {
            XCTFail()
        }
    }

    func testFetchGravatarProfileEmptyError() async throws {
        let session = URLSessionMock(returnData: emptyJsonData, response: .successResponse())
        let client = URLSessionHTTPClient(urlSession: session)
        let service = ProfileService(client: client)

        do {
            _ = try await service.fetch(with: .email("some@email.com"))
        } catch let error as ProfileServiceError {
            XCTAssertEqual(error.debugDescription, ProfileServiceError.noProfileInResponse.debugDescription)
        } catch {
            XCTFail()
        }
    }

    func testFetchGravatarProfileWithCompletionHandler() {
        let session = URLSessionMock(returnData: jsonData, response: .successResponse())
        let client = URLSessionHTTPClient(urlSession: session)
        let service = ProfileService(client: client)
        let expectation = expectation(description: "request finishes")

        service.fetchProfile(with: .email("some@email.com")) { result in
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

        service.fetchProfile(with: .email("some@email.com")) { result in
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

    func testFetchGravatarProfileLastEditDate() async throws {
        let session = URLSessionMock(returnData: jsonData, response: .successResponse())
        let client = URLSessionHTTPClient(urlSession: session)
        let service = ProfileService(client: client)
        let profile = try await service.fetch(with: .email("some@email.com"))

        XCTAssertEqual(profile.displayName, "Beau Lebens")
        XCTAssertNotNil(profile.lastProfileEdit)
    }

    func testFetchGravatarProfileURLs() async throws {
        let session = URLSessionMock(returnData: jsonData, response: .successResponse())
        let client = URLSessionHTTPClient(urlSession: session)
        let service = ProfileService(client: client)
        let profile = try await service.fetch(with: .email("some@email.com"))

        XCTAssertEqual(profile.urls.first?.linkSlug, "some_slug")
        XCTAssertNotNil(profile.lastProfileEdit)
    }

    func testFetchGravatarProfileJustCreated() async throws {
        let session = URLSessionMock(returnData: minimalJsonData, response: .successResponse())
        let client = URLSessionHTTPClient(urlSession: session)
        let service = ProfileService(client: client)

        do {
            let profile = try await service.fetch(with: .email("some@email.com"))
            XCTAssertEqual(profile.displayName, "doxomi4985")
        } catch {
            XCTFail(error.localizedDescription)
        }
    }

    func testFetchWithEmail() async throws {
        let session = URLSessionMock(returnData: jsonData, response: .successResponse())
        let client = HTTPClientMock(session: session)
        let service = ProfileService(client: client)
        _ = try await service.fetch(with: .email("some@email.com"))

        XCTAssertEqual(
            session.request?.url?.absoluteString,
            "https://gravatar.com/676212ff796c79a3c06261eb10e3f455aa93998ee6e45263da13679c74b1e674.json"
        )
    }

    func testFetchWithHash() async throws {
        let session = URLSessionMock(returnData: jsonData, response: .successResponse())
        let client = HTTPClientMock(session: session)
        let service = ProfileService(client: client)
        _ = try await service.fetch(with: .hashID("HASH"))

        XCTAssertEqual(session.request?.url?.absoluteString, "https://gravatar.com/HASH.json")
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
                {
                    "title": "My site verified",
                    "value": "http://test.com/",
                    "link_slug": "some_slug"
                }
            ],
            "share_flags": {
                "search_engines": true
            }
        }
    ]
}
""".data(using: .utf8)!

// User just created. The minimum amount of info. (email: doxomi4985@aersm.com)
let minimalJsonData: Data = """
{
  "entry": [
    {
      "hash": "2437c5959b925a1d574d1a2ca1a457ef",
      "requestHash": "2437c5959b925a1d574d1a2ca1a457ef",
      "profileUrl": "https://gravatar.com/doxomi4985",
      "preferredUsername": "doxomi4985",
      "thumbnailUrl": "https://1.gravatar.com/avatar/2437c5959b925a1d574d1a2ca1a457ef",
      "photos": [
        {
          "value": "https://1.gravatar.com/avatar/2437c5959b925a1d574d1a2ca1a457ef",
          "type": "thumbnail"
        }
      ],
      "displayName": "doxomi4985",
      "urls": [],
      "score": {
        "value": 1,
        "full": {
          "photos": 0,
          "last_profile_edit": 0,
          "displayName": 1,
          "hidden_contact_info": 0,
          "hidden_wallet": 0,
          "urls": 0,
          "hidden_avatar": 0,
          "age": 0
        },
        "accountable": {
          "displayName": 1
        }
      }
    }
  ]
}
""".data(using: .utf8)!

private let emptyJsonData = """
{
    "entry": []
}
""".data(using: .utf8)!
