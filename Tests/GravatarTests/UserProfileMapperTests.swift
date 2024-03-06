import Gravatar
import XCTest

final class UserProfileMapperTests: XCTestCase {
    private typealias ProfileName = [String: String]
    private typealias ProfileLinkURL = [String: String]
    private typealias ProfilePhoto = [String: String]
    private typealias ProfileEmail = [String: Any]
    private typealias ProfileAccount = [String: String]

    private let url = URL(string: "http://a-url.com")!

    private enum TestProfile {
        static let hash: String = "22bd03ace6f176bfe0c593650bcf45d8"
        static let requestHash: String = "205e460b479e2e5b48aec07710c08d50"
        static let preferredUsername: String = "testuser"
        static let displayName: String = "testdisplayname"
        static let profileUrl: String = "http://a-url.com/profile"
        static let thumbnailUrl: String = "http://a-url.com/thumb"
        static let pronouns: String = "test/tester/testing"
        static let aboutMe: String = "test bio"
        static let lastProfileEdit: String = "2024-03-05 21:49:31"
        static let name: ProfileName = profileName(
            givenName: "testname",
            familyName: "testfamilyname",
            formatted: "testname testfamilyname"
        )
        static let photos: [ProfilePhoto] = [
            profilePhoto(
                value: "https://0.gravatar.com/avatar/22bd03ace6f176bfe0c593650bcf45d8",
                type: "thumbnail"
            ),
        ]
        static let urls: [ProfileLinkURL] = [
            profileUrl(
                title: "url title",
                value: "http://a-url.com",
                linkSlug: nil
            ),
        ]
        static let emailsBool: [ProfileEmail] = [
            profileEmail(primary: true, value: "test@example.com"),
        ]
        static let emailsString: [ProfileEmail] = [
            profileEmail(primary: "true", value: "test@example.com"),
        ]
        static let accounts: [ProfileAccount] = [
            profileAccount(
                domain: "test.example.com",
                display: "display.example.com",
                url: "http://a-url.com",
                iconUrl: "http://a-url.com/icon",
                username: "testname",
                verified: "true",
                name: "testname",
                shortname: "shortname"
            ),
        ]

        static func profileName(name: UserProfile.Name) -> ProfileName {
            profileName(givenName: name.givenName, familyName: name.familyName, formatted: name.formatted)
        }

        static func profilePhoto(photo: UserProfile.Photo) -> ProfilePhoto {
            profilePhoto(value: photo.value, type: photo.type)
        }

        static func profileUrl(url: UserProfile.LinkURL) -> ProfileLinkURL {
            profileUrl(title: url.title, value: url.value, linkSlug: url.linkSlug)
        }

        static func profileEmail(email: UserProfile.Email) -> ProfileEmail {
            profileEmail(primary: email.primary, value: email.value)
        }

        static func profileAccount(account: UserProfile.Account) -> ProfileAccount {
            profileAccount(
                domain: account.domain,
                display: account.display,
                url: account.url,
                iconUrl: account.iconUrl,
                username: account.username,
                verified: account.verified,
                name: account.name,
                shortname: account.shortname
            )
        }

        private static func profileName(givenName: String, familyName: String, formatted: String) -> ProfileName {
            [
                "givenName": givenName,
                "familyName": familyName,
                "formatted": formatted,
            ]
        }

        private static func profilePhoto(value: String, type: String) -> ProfilePhoto {
            [
                "value": value,
                "type": type,
            ]
        }

        private static func profileUrl(title: String, value: String, linkSlug: String?) -> ProfileLinkURL {
            [
                "title": title,
                "value": value,
                "link_slug": linkSlug,
            ].compactMapValues { $0 }
        }

        private static func profileEmail(primary: some Codable, value: String) -> ProfileEmail {
            [
                "primary": primary,
                "value": value,
            ]
        }

        private static func profileAccount(
            domain: String,
            display: String,
            url: String,
            iconUrl: String,
            username: String,
            verified: String,
            name: String,
            shortname: String
        ) -> ProfileAccount {
            [
                "domain": domain,
                "display": display,
                "url": url,
                "iconUrl": iconUrl,
                "username": username,
                "verified": verified,
                "name": name,
                "shortname": shortname,
            ]
        }
    }

    func testInvalidUserProfile() async {
        let data = makeProfileJSON([[:]])
        let urlSession = URLSessionMock(returnData: data, response: HTTPURLResponse())
        let client = HTTPClientMock(session: urlSession)
        let profileService = ProfileService(client: client)

        do {
            let _ = try await profileService.fetchProfile(with: URLRequest(url: url))
        } catch let error as ProfileServiceError {
            XCTAssertEqual(error.debugDescription, ProfileServiceError.noProfileInResponse.debugDescription)
        } catch {
            XCTFail("Should have thrown a ProfileServiceError")
        }
    }

    func testBasicUserProfile() async throws {
        let json = makeProfile(
            hash: TestProfile.hash,
            requestHash: TestProfile.requestHash,
            preferredUsername: TestProfile.preferredUsername,
            displayName: TestProfile.displayName,
            urls: [],
            photos: TestProfile.photos,
            profileUrl: TestProfile.profileUrl,
            thumbnailUrl: TestProfile.thumbnailUrl
        )
        let urlSession = URLSessionMock(returnData: makeProfileJSON([json]), response: HTTPURLResponse())
        let client = HTTPClientMock(session: urlSession)
        let profileService = ProfileService(client: client)

        let profile = try await profileService.fetchProfile(with: URLRequest(url: url))

        expect(profile: profile)
    }

    func testComprehensiveUserProfile() async throws {
        let json = makeProfile(
            hash: TestProfile.hash,
            requestHash: TestProfile.requestHash,
            preferredUsername: TestProfile.preferredUsername,
            displayName: TestProfile.displayName,
            name: TestProfile.name,
            pronouns: TestProfile.pronouns,
            aboutMe: TestProfile.aboutMe,
            urls: TestProfile.urls,
            photos: TestProfile.photos,
            emails: TestProfile.emailsString,
            accounts: TestProfile.accounts,
            profileUrl: TestProfile.profileUrl,
            thumbnailUrl: TestProfile.thumbnailUrl,
            lastProfileEdit: TestProfile.lastProfileEdit
        )

        let urlSession = URLSessionMock(returnData: makeProfileJSON([json]), response: HTTPURLResponse())
        let client = HTTPClientMock(session: urlSession)
        let profileService = ProfileService(client: client)

        let profile = try await profileService.fetchProfile(with: URLRequest(url: url))
        expect(profile: profile)
    }

    func testComprehensiveUserProfileWithEmailBoolValue() async throws {
        let json = makeProfile(
            hash: TestProfile.hash,
            requestHash: TestProfile.requestHash,
            preferredUsername: TestProfile.preferredUsername,
            displayName: TestProfile.displayName,
            name: TestProfile.name,
            pronouns: TestProfile.pronouns,
            aboutMe: TestProfile.aboutMe,
            urls: TestProfile.urls,
            photos: TestProfile.photos,
            emails: TestProfile.emailsBool,
            accounts: TestProfile.accounts,
            profileUrl: TestProfile.profileUrl,
            thumbnailUrl: TestProfile.thumbnailUrl,
            lastProfileEdit: TestProfile.lastProfileEdit
        )
        let urlSession = URLSessionMock(returnData: makeProfileJSON([json]), response: HTTPURLResponse())
        let client = HTTPClientMock(session: urlSession)
        let profileService = ProfileService(client: client)

        do {
            let profile = try await profileService.fetchProfile(with: URLRequest(url: url))
            expect(profile: profile)
        } catch {
            XCTFail()
        }
    }

    private func makeProfileJSON(_ entry: [[String: Any]]) -> Data {
        let json = ["entry": entry]
        return try! JSONSerialization.data(withJSONObject: json)
    }

    private func makeProfile(
        hash: String,
        requestHash: String,
        preferredUsername: String,
        displayName: String,
        name: ProfileName? = nil,
        pronouns: String? = nil,
        aboutMe: String? = nil,
        urls: [ProfileLinkURL] = [],
        photos: [ProfilePhoto] = [],
        emails: [ProfileEmail]? = nil,
        accounts: [ProfileAccount]? = nil,
        profileUrl: String,
        thumbnailUrl: String,
        lastProfileEdit: String? = nil

    ) -> [String: Any] {
        let json: [String: Any?] = [
            "hash": hash,
            "requestHash": requestHash,
            "profileUrl": profileUrl,
            "preferredUsername": preferredUsername,
            "thumbnailUrl": thumbnailUrl,
            "photos": photos,
            "last_profile_edit": lastProfileEdit,
            "displayName": displayName,
            "pronouns": pronouns,
            "aboutMe": aboutMe,
            "name": name,
            "accounts": accounts,
            "emails": emails,
            "urls": urls,
        ]

        return json.compactMapValues { $0 }
    }

    private func expect(
        profile: UserProfile,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        XCTAssertEqual(profile.hash, TestProfile.hash)
        XCTAssertEqual(profile.requestHash, TestProfile.requestHash)
        XCTAssertEqual(profile.photos.count, TestProfile.photos.count)

        for (index, photo) in profile.photos.enumerated() {
            XCTAssertEqual(TestProfile.profilePhoto(photo: photo), TestProfile.photos[index])
        }

        XCTAssertEqual(profile.preferredUsername, TestProfile.preferredUsername)
        XCTAssertEqual(profile.displayName, TestProfile.displayName)
        XCTAssertEqual(profile.profileURL, URL(string: TestProfile.profileUrl))
        XCTAssertEqual(profile.thumbnailURL, URL(string: TestProfile.thumbnailUrl))

        for (index, url) in profile.urls.enumerated() {
            XCTAssertEqual(TestProfile.profileUrl(url: url), TestProfile.urls[index])
        }
    }
}

private struct HTTPClientMock: HTTPClient {
    private let session: URLSessionMock

    init(session: URLSessionMock) {
        self.session = session
    }

    func fetchData(with request: URLRequest) async throws -> (Data, HTTPURLResponse) {
        (session.returnData, session.response)
    }

    func uploadData(with request: URLRequest, data: Data) async throws -> HTTPURLResponse {
        session.response
    }
}

private let emptyJsonData = """
{
    "entry": []
}
""".data(using: .utf8)!

// private let basicProfile = [
//    "hash":
// ]

private let basicProfileJsonData = """
{
    "entry": [
        {
            "hash": "2abc869bdcc50e92d61dc7fb897fa492",
            "requestHash": "admtest14b1fe874a0",
            "profileUrl": "https://gravatar.com/admtest14b1fe874a0",
            "preferredUsername": "admtest14b1fe874a0",
            "thumbnailUrl": "https://0.gravatar.com/avatar/2abc869bdcc50e92d61dc7fb897fa492",
            "photos": [
                {
                    "value": "https://0.gravatar.com/avatar/2abc869bdcc50e92d61dc7fb897fa492",
                    "type": "thumbnail"
                }
            ],
            "displayName": "admtest14b1fe874a0",
            "urls": []
        }
    ]
}
""".data(using: .utf8)!
