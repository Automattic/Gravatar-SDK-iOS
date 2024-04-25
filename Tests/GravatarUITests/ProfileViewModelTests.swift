import Combine
@testable import Gravatar
import GravatarUI
import SnapshotTesting
import XCTest

final class ProfileViewModelTests: XCTestCase {
    private var cancellables: Set<AnyCancellable> = []

    override func setUp() {
        super.setUp()
        cancellables = []
    }

    @MainActor
    func testIsLoadingUpdatesOnSuccess() async throws {
        let viewModel = ProfileViewModel(profileService: successfulService())
        var states: [Bool] = []
        viewModel.$isLoading.sink { isLoading in
            states.append(isLoading)
        }.store(in: &cancellables)
        await viewModel.fetchProfile(profileIdentifier: .email("test@email.com"))
        XCTAssertEqual(states, [false, true, false])
    }

    @MainActor
    func testIsLoadingUpdatesOnFailure() async throws {
        let viewModel = ProfileViewModel(profileService: failingService())
        var states: [Bool] = []
        viewModel.$isLoading.sink { isLoading in
            states.append(isLoading)
        }.store(in: &cancellables)
        await viewModel.fetchProfile(profileIdentifier: .email("test@email.com"))
        XCTAssertEqual(states, [false, true, false])
    }

    @MainActor
    func testProfileFetchingResultUpdatesOnSuccess() async throws {
        let viewModel = ProfileViewModel(profileService: successfulService())
        var states: [Result<UserProfile, ProfileServiceError>?] = []
        viewModel.$profileFetchingResult.sink { result in
            states.append(result)
        }.store(in: &cancellables)
        await viewModel.fetchProfile(profileIdentifier: .email("test@email.com"))
        XCTAssertEqual(states.count, 2)
        XCTAssertTrue(states[0] == nil)
        XCTAssertNotNil(try states[1]?.get() as? UserProfile)
    }

    @MainActor
    func testProfileFetchingResultUpdatesOnFailure() async throws {
        let viewModel = ProfileViewModel(profileService: failingService())
        var states: [Result<UserProfile, ProfileServiceError>?] = []
        viewModel.$profileFetchingResult.sink { result in
            states.append(result)
        }.store(in: &cancellables)
        await viewModel.fetchProfile(profileIdentifier: .email("test@email.com"))
        XCTAssertEqual(states.count, 2)
        XCTAssertTrue(states[0] == nil)
        let result = try XCTUnwrap(states[1])
        switch result {
        case .success:
            XCTFail("The result should haven been a failure")
        case .failure:
            break
        }
    }

    func successfulService() -> ProfileService {
        let session = URLSessionMock(returnData: jsonData, response: .successResponse())
        let client = URLSessionHTTPClient(urlSession: session)
        return ProfileService(client: client)
    }

    func failingService() -> ProfileService {
        let session = URLSessionMock(returnData: jsonData, response: .errorResponse(code: 404))
        let client = URLSessionHTTPClient(urlSession: session)
        return ProfileService(client: client)
    }
}

// The minimum amount of info. (email: doxomi4985@aersm.com)
let jsonData: Data = """
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
