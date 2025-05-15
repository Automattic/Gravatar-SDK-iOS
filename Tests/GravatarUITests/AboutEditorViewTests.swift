import Foundation
@testable import GravatarUI
import SnapshotTesting
import TestHelpers
import Testing

@Suite(.snapshots(record: .failed, diffTool: .ksdiff))
struct AboutEditorViewTests {
    @MainActor
    @Test
    func testAboutEditorViewAllFieldsIntrinsicHeight() async throws {
        let testModel = testModel()
        await testModel.refresh(modelToRefresh: .aboutEditorModel)

        let view = AboutEditorView(
            isPresented: .constant(true),
            model: testModel,
            fields: .all
        )
        .fixedSize(horizontal: false, vertical: true)
        .frame(width: ViewImageConfig.iPhone13Pro.size?.width ?? 0)

        assertSnapshots(
            of: view,
            as: [
                .testStrategy(userInterfaceStyle: .light, layout: .sizeThatFits),
                .testStrategy(userInterfaceStyle: .dark, layout: .sizeThatFits),
            ]
        )
    }

    @MainActor
    @Test
    func testAboutEditorViewProfessionalFieldsIntrinsicHeight() async throws {
        let testModel = testModel()
        await testModel.refresh(modelToRefresh: .aboutEditorModel)

        let view = AboutEditorView(
            isPresented: .constant(true),
            model: testModel,
            fields: .professionalFields
        )
        .fixedSize(horizontal: false, vertical: true)
        .frame(width: ViewImageConfig.iPhone13Pro.size?.width ?? 0)

        assertSnapshots(
            of: view,
            as: [
                .testStrategy(userInterfaceStyle: .light, layout: .sizeThatFits),
                .testStrategy(userInterfaceStyle: .dark, layout: .sizeThatFits),
            ]
        )
    }

    @MainActor
    @Test
    func testAboutEditorViewPersonalFieldsIntrinsicHeight() async throws {
        let testModel = testModel()
        await testModel.refresh(modelToRefresh: .aboutEditorModel)

        let view = AboutEditorView(
            isPresented: .constant(true),
            model: testModel,
            fields: .personalFields
        )
        .fixedSize(horizontal: false, vertical: true)
        .frame(width: ViewImageConfig.iPhone13Pro.size?.width ?? 0)

        assertSnapshots(
            of: view,
            as: [
                .testStrategy(userInterfaceStyle: .light, layout: .sizeThatFits),
                .testStrategy(userInterfaceStyle: .dark, layout: .sizeThatFits),
            ]
        )
    }

    @MainActor
    @Test
    func testAboutEditorViewAllFieldsFixedHeight() async throws {
        let testModel = testModel()
        await testModel.refresh(modelToRefresh: .aboutEditorModel)
        let viewImageConfig: ViewImageConfig = .iPhoneSe

        let view = AboutEditorView(
            isPresented: .constant(true),
            model: testModel,
            fields: .all
        )

        assertSnapshots(
            of: view,
            as: [
                .testStrategy(userInterfaceStyle: .light, layout: .device(config: viewImageConfig)),
                .testStrategy(userInterfaceStyle: .dark, layout: .device(config: viewImageConfig)),
            ]
        )
    }

    @MainActor
    @Test
    func testAboutEditorWithUnsavedChanges() async throws {
        let testModel = testModel()
        await testModel.refresh(modelToRefresh: .aboutEditorModel)
        let viewImageConfig: ViewImageConfig = .iPhoneSe

        let view = AboutEditorView(
            isPresented: .constant(true),
            model: testModel,
            fields: .all
        )

        testModel.aboutInfoModel.displayName = "New Unsaved Name"

        assertSnapshots(
            of: view,
            as: [
                .testStrategy(userInterfaceStyle: .light, layout: .device(config: viewImageConfig)),
                .testStrategy(userInterfaceStyle: .dark, layout: .device(config: viewImageConfig)),
            ]
        )
    }

    @MainActor
    @Test
    func testAboutEditorViewOneFieldFixedHeight() async throws {
        let testModel = testModel()
        await testModel.refresh(modelToRefresh: .aboutEditorModel)
        let viewImageConfig: ViewImageConfig = .iPhoneSe

        let view = AboutEditorView(
            isPresented: .constant(true),
            model: testModel,
            fields: .displayName
        )

        assertSnapshots(
            of: view,
            as: [
                .testStrategy(userInterfaceStyle: .light, layout: .device(config: viewImageConfig)),
                .testStrategy(userInterfaceStyle: .dark, layout: .device(config: viewImageConfig)),
            ]
        )
    }

    @MainActor
    @Test("Test about editor loading state snapshot")
    func testLoadingState() async throws {
        let testModel = testModel()

        let view = AboutEditorView(
            isPresented: .constant(true),
            model: testModel,
            fields: .all
        )

        Task(priority: .high) {
            await testModel.fetchProfile()
        }
        // Awaits for the previous task to start executing, and the view to start loading.
        try await Task.sleep(nanoseconds: 1)
        assertSnapshots(
            of: view,
            as: [
                .testStrategy(userInterfaceStyle: .light, layout: .fixed(width: 200, height: 300)),
                .testStrategy(userInterfaceStyle: .dark, layout: .fixed(width: 200, height: 300)),
            ]
        )
    }

    @MainActor
    @Test("Test about editor shows loading error")
    func testLoadingErrorState() async throws {
        let testModel = testModel(response: .errorResponse(code: 401))
        let viewImageConfig: ViewImageConfig = .iPhoneSe

        let view = AboutEditorView(
            isPresented: .constant(true),
            model: testModel,
            fields: .all
        )

        await testModel.fetchProfile()

        assertSnapshots(
            of: view,
            as: [
                .testStrategy(userInterfaceStyle: .light, layout: .device(config: viewImageConfig)),
                .testStrategy(userInterfaceStyle: .dark, layout: .device(config: viewImageConfig)),
            ]
        )
    }

    @MainActor
    private func testModel(response: HTTPURLResponse = .successResponse()) -> AvatarPickerViewModel {
        let profileService = ProfileService(urlSession: URLSessionMock(returnData: Bundle.fullProfileJsonData, response: response))

        let imageURL = "https://gravatar.com/avatar/HASH"
        let response = HTTPURLResponse.successResponse(with: URL(string: imageURL)!)
        let imageDownloadService = ImageDownloadService(
            urlSession: URLSessionMock(returnData: ImageHelper.testImageData, response: response),
            cache: TestImageCache()
        )
        let avatarService = AvatarService(urlSession: URLSessionMock(returnData: Bundle.getAvatarsJsonData, response: .successResponse()))

        return .init(
            email: .init("test@domain.com"),
            authToken: "FakeToken",
            profileService: profileService,
            avatarService: avatarService,
            imageDownloader: imageDownloadService
        )
    }
}
