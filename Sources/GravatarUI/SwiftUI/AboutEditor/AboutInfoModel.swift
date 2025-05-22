import SwiftUI

class AboutInfoModel: ObservableObject {
    @Published var displayName: String = ""
    @Published var aboutMe: String = ""
    @Published var pronunciation: String = ""
    @Published var pronouns: String = ""
    @Published var location: String = ""
    @Published var jobTitle: String = ""
    @Published var company: String = ""
    @Published var firstName: String = ""
    @Published var lastName: String = ""

    init() {}

    init(
        displayName: String,
        aboutMe: String,
        pronunciation: String,
        pronouns: String,
        location: String,
        jobTitle: String,
        company: String,
        firstName: String,
        lastName: String
    ) {
        self.displayName = displayName
        self.aboutMe = aboutMe
        self.pronunciation = pronunciation
        self.pronouns = pronouns
        self.location = location
        self.jobTitle = jobTitle
        self.company = company
        self.firstName = firstName
        self.lastName = lastName
    }

    func updateProfileRequest(for fields: AboutInfoField) -> UpdateProfileRequest {
        UpdateProfileRequest(
            firstName: fields.contains(.firstName) ? firstName : nil,
            lastName: fields.contains(.lastName) ? lastName : nil,
            displayName: fields.contains(.displayName) ? displayName : nil,
            description: fields.contains(.aboutMe) ? aboutMe : nil,
            pronunciation: fields.contains(.pronunciation) ? pronunciation : nil,
            pronouns: fields.contains(.pronouns) ? pronouns : nil,
            location: fields.contains(.location) ? location : nil,
            jobTitle: fields.contains(.jobTitle) ? jobTitle : nil,
            company: fields.contains(.company) ? company : nil
        )
    }
}
