@testable import GravatarUI
import TestHelpers
import Testing

struct AvatarImageModelTests {
    @Test("Check URL exists")
    func testURLExists() async throws {
        let imageURL = "https://example.com/avatar.jpg"
        let model = AvatarImageModel(id: "someID", source: .remote(url: imageURL))
        #expect(model.url?.absoluteString == imageURL)
        #expect(model.localImage == nil)
    }

    @Test("Check local image exists")
    func testLocalImageExists() async throws {
        let model = AvatarImageModel(id: "someID", source: .local(image: ImageHelper.testImage))
        #expect(model.localImage != nil)
        #expect(model.localUIImage != nil)
        #expect(model.url == nil)
    }

    @Test("Check state change from loading to loaded")
    func testStateChangeLoadingLoaded() async throws {
        let model = AvatarImageModel(id: "someID", source: .local(image: ImageHelper.testImage), state: .loading)
        #expect(model.state == .loading)

        let loadedModel = model.settingStatus(to: .loaded)
        #expect(loadedModel.state == .loaded, "The state should be .loaded")
    }

    @Test("Check state change from loading to error")
    func testStateChangeLoadingError() async throws {
        let model = AvatarImageModel(id: "someID", source: .local(image: ImageHelper.testImage), state: .loading)
        #expect(model.state == .loading)

        let loadedModel = model.settingStatus(to: .error(supportsRetry: true, errorMessage: "Some Error"))
        switch loadedModel.state {
        case .error:
            #expect(Bool(true))
        default: #expect(Bool(false), "The state should be .error")
        }
    }
}
