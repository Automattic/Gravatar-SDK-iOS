import Combine
@testable import Gravatar
import GravatarUI
import SnapshotTesting
@testable import TestHelpers
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
        var states: [Result<Profile, APIError>?] = []
        viewModel.$profileFetchingResult.sink { result in
            states.append(result)
        }.store(in: &cancellables)
        await viewModel.fetchProfile(profileIdentifier: .email("test@email.com"))
        XCTAssertEqual(states.count, 2)
        XCTAssertTrue(states[0] == nil)
        XCTAssertNotNil(try states[1]?.get() as? Profile)
    }

    @MainActor
    func testProfileFetchingResultUpdatesOnFailure() async throws {
        let viewModel = ProfileViewModel(profileService: failingService())
        var states: [Result<Profile, APIError>?] = []
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
  "hash": "somehash",
  "display_name": "Edu",
  "profile_url": "https://gravatar.com/some",
  "avatar_url": "https://0.gravatar.com/avatar/somehash",
  "avatar_alt_text": "",
  "location": "Nowhereland",
  "description": "",
  "job_title": "",
  "company": "",
  "verified_accounts": [],
  "pronunciation": "",
  "pronouns": ""
}
""".data(using: .utf8)!
