import Combine
import Foundation
@testable import Gravatar
@testable import GravatarUI
import TestHelpers
import Testing

@MainActor
final class AvatarPickerViewModelTests {
    var cancellables = Set<AnyCancellable>()
    var model: AvatarPickerViewModel

    init() {
        model = Self.createModel()
    }

    static func createModel(
        session: URLSessionAvatarPickerMock = .init(),
        imageDownloader: ImageDownloader = TestImageFetcher(result: .success)
    ) -> AvatarPickerViewModel {
        .init(
            email: .init("some@email.com"),
            authToken: "token",
            profileService: ProfileService(urlSession: session),
            avatarService: AvatarService(urlSession: session),
            imageDownloader: imageDownloader
        )
    }

    static func createImageModel(id: String, source: AvatarImageModel.Source, isSelected: Bool = false) -> AvatarImageModel {
        .init(
            id: id,
            source: source,
            state: .loaded,
            isSelected: isSelected,
            rating: .g,
            altText: "fake alt text"
        )
    }

    @Test
    func testFirstAvatarsAreLoaded() async throws {
        await confirmation { confirmation in
            model.grid.$avatars.dropFirst().sink { avatarModels in
                #expect(avatarModels.count == 5)
                confirmation.confirm()
            }.store(in: &cancellables)

            await model.refresh()
        }
    }

    @Test
    func testProfileIsLoaded() async throws {
        await confirmation { confirmation in
            model.$profileModel.dropFirst().sink { profileModel in
                #expect(profileModel?.displayName == "John Appleseed")
                confirmation.confirm()
            }.store(in: &cancellables)

            await model.refresh()
        }
    }

    @Test
    func testSelectAvatar() async throws {
        let toSelectID = "9862792c565394..."
        await model.refresh()
        await confirmation { confirmation in
            // First selectedAvatar change after setting the initial status.
            // Second selectedAvatar change is local set before the request.
            // Third selectedAvatar change is after the request, and the one we are interested in.
            model.grid.$selectedAvatar.dropFirst(2).sink { selected in
                #expect(selected?.isSelected == true)
                #expect(selected?.id == toSelectID)
                confirmation.confirm()
            }.store(in: &cancellables)
            let selected = await model.selectAvatar(with: toSelectID)
            #expect(selected?.id == toSelectID)
        }
    }

    @Test
    func testFetchOriginalSizeAvatarSuccess() async throws {
        await model.refresh()
        let avatar = try #require(model.grid.avatars.first, "No avatar found")

        await confirmation(expectedCount: 2) { confirmation in
            model.toastManager.$toasts.sink { toasts in
                #expect(toasts.count == 0, "No toast should be shown in success case")
                confirmation.confirm()
            }.store(in: &cancellables)

            var observedStates: [AvatarImageModel.State] = []
            model.grid.$avatars.sink { models in
                observedStates.append(models[0].state)
                if observedStates.count == 3 {
                    #expect(observedStates[0] == .loaded)
                    #expect(observedStates[1] == .loading)
                    #expect(observedStates[2] == .loaded)
                    confirmation.confirm()
                }
            }.store(in: &cancellables)
            let result = await model.fetchOriginalSizeAvatar(for: avatar)
            #expect(result != nil)
        }
    }

    @Test
    func testFetchOriginalSizeFailsWithURLSessionError() async throws {
        let model = Self.createModel(imageDownloader: TestImageFetcher(result: .urlSessionError))
        await model.refresh()
        let avatar = try #require(model.grid.avatars.first, "No avatar found")

        await confirmation(expectedCount: 2) { confirmation in
            model.toastManager.$toasts.sink { toasts in
                #expect(toasts.count <= 1)
                if toasts.count == 1 {
                    #expect(toasts.first?.message == TestImageFetcher.sessionErrorMessage)
                    #expect(toasts.first?.type == .error)
                    confirmation.confirm()
                }
            }.store(in: &cancellables)

            var observedStates: [AvatarImageModel.State] = []
            model.grid.$avatars.sink { models in
                observedStates.append(models[0].state)
                if observedStates.count == 3 {
                    #expect(observedStates[0] == .loaded)
                    #expect(observedStates[1] == .loading)
                    #expect(observedStates[2] == .loaded)
                    confirmation.confirm()
                }
            }.store(in: &cancellables)
            let result = await model.fetchOriginalSizeAvatar(for: avatar)
            #expect(result == nil)
        }
    }

    @Test
    func testFetchOriginalSizeFailsWithGenericError() async throws {
        let model = Self.createModel(imageDownloader: TestImageFetcher(result: .fail))
        await model.refresh()
        let avatar = try #require(model.grid.avatars.first, "No avatar found")

        await confirmation(expectedCount: 2) { confirmation in
            model.toastManager.$toasts.sink { toasts in
                #expect(toasts.count <= 1)
                if toasts.count == 1 {
                    #expect(toasts.first?.message == AvatarPickerViewModel.Localized.avatarShareFail)
                    #expect(toasts.first?.type == .error)
                    confirmation.confirm()
                }
            }.store(in: &cancellables)

            var observedStates: [AvatarImageModel.State] = []
            model.grid.$avatars.sink { models in
                observedStates.append(models[0].state)
                if observedStates.count == 3 {
                    #expect(observedStates[0] == .loaded)
                    #expect(observedStates[1] == .loading)
                    #expect(observedStates[2] == .loaded)
                    confirmation.confirm()
                }
            }.store(in: &cancellables)
            let result = await model.fetchOriginalSizeAvatar(for: avatar)
            #expect(result == nil)
        }
    }

    @Test
    func testUploadAvatar() async throws {
        model.grid.setAvatars([])

        await confirmation { confirmation in
            model.grid.$avatars.dropFirst(2).sink { avatars in
                #expect(avatars.count == 1)
                let avatar = avatars.first!
                #expect(avatar.state == .loaded)
                switch avatar.source {
                case .remote: #expect(Bool(true))
                default: #expect(Bool(false))
                }
                confirmation.confirm()
            }.store(in: &cancellables)

            await model.upload(ImageHelper.exampleAvatarImage, shouldSquareImage: false)

            #expect(model.grid.avatars.count == 1)
        }
    }

    @Test
    func testUploadErrorTooLarge() async throws {
        model = Self.createModel(session: .init(returnErrorCode: HTTPStatus.payloadTooLarge.rawValue))
        model.grid.setAvatars([])

        await confirmation { confirmation in
            model.grid.$avatars.dropFirst(2).sink { avatars in
                #expect(avatars.count == 1, "Expect to be one avatar on the grid")
                let avatar = avatars.first!

                // Expect the avatar status to be Error (non retry-able)
                switch avatar.state {
                case .error(let supportsRetry, _):
                    #expect(!supportsRetry, "Image too large should not support retry")
                default:
                    #expect(Bool(false))
                }

                // Expect the image source to be local
                switch avatar.source {
                case .local: #expect(Bool(true))
                default: #expect(Bool(false))
                }

                #expect(avatar.localImage != nil, "Expect the local image to exist")
                confirmation.confirm()
            }.store(in: &cancellables)

            await model.upload(ImageHelper.exampleAvatarImage, shouldSquareImage: false)

            #expect(model.grid.avatars.count == 1)
        }
    }

    @Test
    func testDeleteAvatar() async throws {
        await model.refresh()
        let avatarToDelete = model.grid.avatars.last!
        #expect(await model.delete(avatarToDelete), "Avatar deletion should be successfull")
        #expect(model.grid.index(of: avatarToDelete.id) == nil, "Deleted avatar should not be on the grid")
    }

    @Test
    func testDeletingNonExistentAvatarFails() async throws {
        await model.refresh()
        let avatarToDelete = Self.createImageModel(id: "someID", source: .remote(url: ""))
        #expect(await model.delete(avatarToDelete) == false, "Avatar deletion should not succeed")
    }

    @Test
    func testDeleteSelectedAvatar() async throws {
        await model.refresh()
        let selectedAvatar = model.grid.selectedAvatar!

        await confirmation { confirmation in
            model.$selectedAvatarURL.dropFirst(2).sink { url in
                #expect(url == nil)
                confirmation.confirm()
            }.store(in: &cancellables)

            #expect(await model.delete(selectedAvatar))
        }

        #expect(model.grid.selectedAvatar == nil)
        #expect(model.selectedAvatarURL == nil)
    }

    @Test("Test success deletion when the response is a 404 error")
    func testDeleteError404() async throws {
        let avatarToDelete = Self.createImageModel(id: "1", source: .remote(url: ""))
        model = Self.createModel(session: .init(returnErrorCode: HTTPStatus.notFound.rawValue))
        model.grid.setAvatars([avatarToDelete])

        #expect(await model.delete(avatarToDelete))
        #expect(model.grid.index(of: avatarToDelete.id) == nil)
    }

    @Test("Test success deletion of selected avatar when the response is a 404 error")
    func testDeleteSelectedAvatarError404() async throws {
        let avatarToDelete = Self.createImageModel(id: "1", source: .remote(url: ""), isSelected: true)
        model = Self.createModel(session: .init(returnErrorCode: HTTPStatus.notFound.rawValue))
        model.grid.setAvatars([avatarToDelete])
        #expect(model.grid.selectedAvatar != nil)

        await confirmation { confirmation in
            model.$selectedAvatarURL.dropFirst(1).sink { url in
                #expect(url == nil)
                confirmation.confirm()
            }.store(in: &cancellables)

            #expect(await model.delete(avatarToDelete))
        }

        #expect(model.grid.selectedAvatar == nil)
        #expect(model.selectedAvatarURL == nil)
        #expect(model.grid.index(of: avatarToDelete.id) == nil)
    }

    @Test("Test error deletion when the response is an error different to 404")
    func testDeleteErrorFails() async throws {
        let avatarToDelete = Self.createImageModel(id: "1", source: .remote(url: ""))
        model = Self.createModel(session: .init(returnErrorCode: HTTPStatus.unauthorized.rawValue))
        model.grid.setAvatars([avatarToDelete])

        #expect(await model.delete(avatarToDelete) == false, "Delete request should fail")
        #expect(model.grid.index(of: avatarToDelete.id) != nil, "Deleting avatar should not have been deleted")
    }

    @Test("Handle avatar rating change: Success")
    func changeAvatarRatingSucceeds() async throws {
        let testAvatarID = "991a7b71cf9f34..."

        await model.refresh()
        let avatar = try #require(model.grid.avatars.first(where: { $0.id == testAvatarID }), "No avatar found")
        try #require(avatar.rating == .g)

        await confirmation { confirmation in
            model.toastManager.$toasts.sink { toasts in
                #expect(toasts.count <= 1)
                if toasts.count == 1 {
                    #expect(toasts.first?.message == AvatarPickerViewModel.Localized.avatarRatingUpdateSuccess)
                    #expect(toasts.first?.type == .info)
                    confirmation.confirm()
                }
            }.store(in: &cancellables)

            await model.update(rating: .pg, for: avatar)
        }
        let resultAvatar = try #require(model.grid.avatars.first(where: { $0.id == testAvatarID }))
        #expect(resultAvatar.rating == .pg)
    }

    @Test(
        "Handle avatar rating change: Failure",
        arguments: [HTTPStatus.unauthorized, .forbidden]
    )
    func changeAvatarRatingReturnsError(httpStatus: HTTPStatus) async throws {
        let testAvatarID = "991a7b71cf9f34..."
        model = Self.createModel(session: .init(returnErrorCode: httpStatus.rawValue))

        await model.refresh()
        let avatar = try #require(model.grid.avatars.first(where: { $0.id == testAvatarID }), "No avatar found")
        try #require(avatar.rating == .g)

        await confirmation { confirmation in
            model.toastManager.$toasts.sink { toasts in
                #expect(toasts.count <= 1)
                if toasts.count == 1 {
                    #expect(toasts.first?.message == AvatarPickerViewModel.Localized.avatarRatingError)
                    #expect(toasts.first?.type == .error)
                    confirmation.confirm()
                }
            }.store(in: &cancellables)

            await model.update(rating: .pg, for: avatar)
        }

        let resultAvatar = try #require(model.grid.avatars.first(where: { $0.id == testAvatarID }))
        #expect(resultAvatar.rating == .g, "The rating should not be changed")
    }

    @Test
    func testUpdateAltText() async throws {
        let newAltText = "Updated Alt Text"
        await model.refresh()
        let avatar = model.grid.avatars[0]

        await confirmToasts { message, type in
            #expect(message?.contains(AvatarPickerViewModel.Localized.avatarAltTextSuccess) == true)
            #expect(type == .info)
        } trigger: {
            let success = await model.update(altText: newAltText, for: avatar)
            #expect(success)
        }

        let updatedAvatar = model.grid.avatars[0]
        #expect(updatedAvatar.altText == newAltText)
    }

    @Test(
        "Handle avatar alt text change: Failure",
        arguments: [HTTPStatus.unauthorized, .forbidden]
    )
    func testUpdateAltTextError(httpStatus: HTTPStatus) async throws {
        model = Self.createModel(session: .init(returnErrorCode: httpStatus.rawValue))
        await model.refresh()
        let avatar = model.grid.avatars[0]
        let originalAltText = avatar.altText

        await confirmToasts { message, type in
            #expect(message == AvatarPickerViewModel.Localized.avatarAltTextError)
            #expect(type == .error)
        } trigger: {
            let success = await model.update(altText: "Updated alt text", for: avatar)
            #expect(success == false)
        }

        let updatedAvatar = model.grid.avatars[0]
        #expect(updatedAvatar.altText == originalAltText, "Alt text should not have changed")
    }
}

extension AvatarPickerViewModelTests {
    func confirmToasts(_ callback: @escaping (String?, ToastType?) -> Void, trigger: () async -> Void) async {
        await confirmation { confirmation in
            model.toastManager.$toasts.sink { toasts in
                #expect(toasts.count <= 1)
                if toasts.count == 1 {
                    callback(toasts.first?.message, toasts.first?.type)
                    confirmation.confirm()
                }
            }.store(in: &cancellables)

            await trigger()
        }
    }
}

final class URLSessionAvatarPickerMock: URLSessionProtocol {
    let returnErrorCode: Int?

    init(returnErrorCode: Int? = nil) {
        self.returnErrorCode = returnErrorCode
    }

    func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        if request.isSetAvatarForEmailRequest {
            return (Bundle.postAvatarSelectedJsonData, HTTPURLResponse.successResponse()) // Avatars data
        }

        if request.isDeleteAvatarRequest {
            if let returnErrorCode {
                return (Data("".utf8), HTTPURLResponse.errorResponse(code: returnErrorCode))
            } else {
                return (Data("".utf8), HTTPURLResponse.successResponse())
            }
        }

        if request.isSetAvatarRatingRequest {
            if let returnErrorCode {
                return (Data("".utf8), HTTPURLResponse.errorResponse(code: returnErrorCode))
            } else {
                return (Bundle.setRatingJsonData, HTTPURLResponse.successResponse()) // Avatar data
            }
        }

        if request.isSetAvatarAltTextRequest {
            if let returnErrorCode {
                return (Data("".utf8), HTTPURLResponse.errorResponse(code: returnErrorCode))
            } else {
                return (Bundle.setAltTextJsonData, HTTPURLResponse.successResponse()) // Avatar data
            }
        }

        if request.isProfilesRequest {
            return (Bundle.fullProfileJsonData, HTTPURLResponse.successResponse()) // Profile data
        } else if request.isAvatarsRequest == true {
            return (Bundle.getAvatarsJsonData, HTTPURLResponse.successResponse()) // Avatars data
        } else if let returnErrorCode {
            return ("{\"error\":\"error\"".data(using: .utf8)!, HTTPURLResponse.errorResponse(code: returnErrorCode))
        }

        fatalError("Request not mocked: \(request.url?.absoluteString ?? "unknown request")")
    }

    func upload(for request: URLRequest, from bodyData: Data) async throws -> (Data, URLResponse) {
        if let returnErrorCode {
            return (Data("".utf8), HTTPURLResponse.errorResponse(code: returnErrorCode))
        }
        return (Bundle.postAvatarUploadJsonData, HTTPURLResponse.successResponse())
    }
}

extension URLRequest {
    private enum RequestType: String {
        case profiles
        case avatars
    }

    fileprivate var isAvatarsRequest: Bool {
        self.url?.absoluteString.contains(RequestType.avatars.rawValue) == true
    }

    fileprivate var isProfilesRequest: Bool {
        self.url?.absoluteString.contains(RequestType.profiles.rawValue) == true
    }

    fileprivate var isDeleteAvatarRequest: Bool {
        guard self.httpMethod == "DELETE",
              self.isAvatarsRequest
        else {
            return false
        }
        return true
    }

    fileprivate var isSetAvatarRatingRequest: Bool {
        guard self.httpMethod == "PATCH",
              self.isAvatarsRequest,
              self.httpBody.isDecodable(asType: UpdateAvatarRequest.self),
              let decodedBody: UpdateAvatarRequest = try? self.httpBody?.decode(),
              decodedBody.rating != nil
        else {
            return false
        }
        return true
    }

    fileprivate var isSetAvatarAltTextRequest: Bool {
        guard
            self.httpMethod == "PATCH",
            self.isAvatarsRequest,
            self.httpBody.isDecodable(asType: UpdateAvatarRequest.self),
            let decodedBody: UpdateAvatarRequest = try? self.httpBody?.decode(),
            decodedBody.altText != nil
        else {
            return false
        }
        return true
    }

    fileprivate var isSetAvatarForEmailRequest: Bool {
        guard self.httpMethod == "POST",
              self.isAvatarsRequest,
              self.httpBody.isDecodable(asType: SetEmailAvatarRequest.self)
        else {
            return false
        }
        return true
    }
}

extension Data? {
    fileprivate func isDecodable<T: Decodable>(asType type: T.Type, using decoder: JSONDecoder = JSONDecoder()) -> Bool {
        guard let self else { return false }
        return (try? decoder.decode(T.self, from: self)) != nil
    }
}
