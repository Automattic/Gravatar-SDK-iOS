@testable import GravatarUI
import Testing

@Suite
struct AboutInfoModelTests {
    @Test
    func testCreateUpdateProfileRequestForAllFields() async throws {
        let model = aboutInfoModel()
        let request = model.updateProfileRequest(for: AboutInfoField.all)
        #expect(request.displayName == model.displayName)
        #expect(request.description == model.aboutMe)
        #expect(request.pronunciation == model.pronunciation)
        #expect(request.pronouns == model.pronouns)
        #expect(request.location == model.location)
        #expect(request.jobTitle == model.jobTitle)
        #expect(request.company == model.company)
    }

    @Test("If the passed `AboutInfoField` set is empty, the request should be empty")
    func testCreateUpdateProfileRequestForEmptySet() async throws {
        let model = aboutInfoModel()
        let request = model.updateProfileRequest(for: [])
        #expect(request.displayName == nil)
        #expect(request.description == nil)
        #expect(request.pronunciation == nil)
        #expect(request.pronouns == nil)
        #expect(request.location == nil)
        #expect(request.jobTitle == nil)
        #expect(request.company == nil)
    }

    private func aboutInfoModel() -> AboutInfoModel {
        AboutInfoModel(
            displayName: "displayName",
            aboutMe: "aboutMe",
            pronunciation: "pronunciation",
            pronouns: "pronouns",
            location: "location",
            jobTitle: "jobTitle",
            company: "company",
            firstName: "fisrtName",
            lastName: "lastName"
        )
    }
}
