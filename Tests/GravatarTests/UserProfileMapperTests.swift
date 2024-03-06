import Gravatar
import XCTest

final class UserProfileMapperTests: XCTestCase {
    private let url = URL(string: "http://a-url.com")!

    private enum TestProfile {
        static let hash: String = "22bd03ace6f176bfe0c593650bcf45d8"
        static let requestHash: String = "205e460b479e2e5b48aec07710c08d50"
        static let preferredUsername: String = "testuser"
        static let displayName: String = "testdisplayname"
        static let profileUrl: String = "http://a-url.com/profile"
        static let thumbnailUrl: String = "http://a-url.com/thumb"
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

        static func profilePhoto(photo: UserProfile.Photo) -> ProfilePhoto {
            profilePhoto(value: photo.value, type: photo.type)
        }

        static func profileUrl(url: UserProfile.LinkURL) -> ProfileLinkURL {
            profileUrl(title: url.title, value: url.value, linkSlug: url.linkSlug)
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
    }

    private func expect(profile: UserProfile) {
        XCTAssertEqual(profile.hash, "22bd03ace6f176bfe0c593650bcf45d8")
        XCTAssertEqual(profile.requestHash, "205e460b479e2e5b48aec07710c08d50")
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
        let data = makeProfileJSON([json])
        let urlSession = URLSessionMock(returnData: data, response: HTTPURLResponse())
        let client = HTTPClientMock(session: urlSession)
        let profileService = ProfileService(client: client)

        let profile = try await profileService.fetchProfile(with: URLRequest(url: url))

        expect(profile: profile)
    }

    private typealias ProfileName = [String: String]
    private typealias ProfileLinkURL = [String: String]
    private typealias ProfilePhoto = [String: String]
    private typealias ProfileEmail = [String: String]
    private typealias ProfileAccount = [String: String]

    private func makeProfileJSON(_ entry: [[String: Any]]) -> Data {
        let json = ["entry": entry]
        return try! JSONSerialization.data(withJSONObject: json)
    }

    private func makeProfile(
        hash: String,
        requestHash: String,
        preferredUsername: String,
        displayName: String,
        name: [ProfileName]? = nil,
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
