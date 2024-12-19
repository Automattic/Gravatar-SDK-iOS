@testable import GravatarUI
import TestHelpers
import Testing

let initialAvatars: [AvatarImageModel] = [
    .preview_init(id: "0", source: .remote(url: "https://example.com/1.jpg")),
    .preview_init(id: "1", source: .remote(url: "https://example.com/1.jpg"), isSelected: true),
    .preview_init(id: "2", source: .remote(url: "https://example.com/1.jpg")),
    .preview_init(id: "3", source: .remote(url: "https://example.com/1.jpg")),
    .preview_init(id: "4", source: .remote(url: "https://example.com/1.jpg")),
]

let initiallySelectedAvatarID = "1"

struct AvatarGridModelTests {
    let model = AvatarGridModel(avatars: [])

    init() {
        model.setAvatars(initialAvatars)
    }

    @Test("Test initial selected avatar")
    func testAvatarGridModel() async throws {
        #expect(model.selectedAvatar?.id == initiallySelectedAvatarID)
    }

    @Test("Test append function")
    func testAvatarGridModelAppend() async throws {
        let appendedAvatar = AvatarImageModel.preview_init(id: "new", source: .remote(url: "https://example.com/1.jpg"))
        model.append(appendedAvatar)

        #expect(model.index(of: "new") == 0)
    }

    @Test("Test select function")
    func testAvatarGridModelSelect() async throws {
        #expect(model.selectedAvatar?.id == initiallySelectedAvatarID)

        model.selectAvatar(withID: "4")

        #expect(model.selectedAvatar?.id == "4")
    }

    @Test("Test select non-existent id won't change selection")
    func testAvatarGridModelSelectFail() async throws {
        #expect(model.selectedAvatar?.id == initiallySelectedAvatarID)

        model.selectAvatar(withID: "non_existing")

        #expect(model.selectedAvatar?.id == initiallySelectedAvatarID)
    }

    @Test("Test select nil will unselect selection")
    func testAvatarGridModelSelectNil() async throws {
        #expect(model.selectedAvatar?.id == initiallySelectedAvatarID)

        model.selectAvatar(withID: nil)

        #expect(model.selectedAvatar?.id == nil)
    }

    @Test("Test indexOf function")
    func testAvatarGridModelIndexOf() async throws {
        #expect(model.index(of: "3") == 3)
        #expect(model.index(of: "non_existing") == nil)
    }

    @Test("Test delete function")
    func testAvatarGridModelDelete() async throws {
        #expect(model.index(of: "3") == 3)
        _ = model.deleteModel("3")
        #expect(model.index(of: "3") == nil)
    }

    @Test("Test set state function")
    func testAvatarGridModelSetState() async throws {
        #expect(model.model(with: "3")?.state == .loaded)
        model.setState(to: .loading, onAvatarWithID: "3")
        #expect(model.model(with: "3")?.state == .loading)
    }

    @Test("Test set state of non-existent avatar does nothing")
    func testAvatarGridModelSetStateNonExistent() async throws {
        #expect(!model.avatars.compactMap(\.state).contains(.loading))
        model.setState(to: .loading, onAvatarWithID: "non_existent")
        #expect(!model.avatars.compactMap(\.state).contains(.loading), "Should not ")
    }

    @Test("Test remove function")
    func testAvatarGridModelRemove() async throws {
        #expect(model.model(with: "3") != nil)
        model.removeModel("3")
        #expect(model.model(with: "3") == nil)
    }

    @Test("Test isEmpty function")
    func testAvatarGridModelisEmpty() async throws {
        #expect(model.isEmpty == false)
        model.setAvatars([])
        #expect(model.isEmpty)
    }

    @Test("Test insert function")
    func testAvatarGridModelInsert() async throws {
        let toInsert = AvatarImageModel.preview_init(id: "new", source: .remote(url: "https://example.com"))
        model.insert(toInsert, at: 2)

        #expect(model.index(of: "new") == 2)
    }
}
