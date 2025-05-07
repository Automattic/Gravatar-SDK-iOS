@testable import GravatarUI
import Testing

@Suite
struct AboutInfoFieldTests {
    @Test
    func testPersonalFields() async throws {
        let fields: AboutInfoField = [
            .displayName,
            .aboutMe,
            .pronunciation,
            .pronouns,
            .location,
        ]
        #expect(AboutInfoField.personalFields.contains(fields), "`AboutInfoField.personalFields` convenience property must contain the necessary fields")
        #expect(AboutInfoField.personalFields.symmetricDifference(fields).isEmpty, "`AboutInfoField.personalFields` convenience must not have unwanted fields")
    }

    @Test
    func testProfessionalFields() async throws {
        let fields: AboutInfoField = [
            .jobTitle,
            .company,
        ]
        #expect(
            AboutInfoField.professionalFields.contains(fields),
            "`AboutInfoField.professionalFields` convenience property must contain the necessary fields"
        )
        #expect(
            AboutInfoField.professionalFields.symmetricDifference(fields).isEmpty,
            "`AboutInfoField.professionalFields` convenience must not have unwanted fields"
        )
    }

    @Test
    func testAllFields() async throws {
        let fields: AboutInfoField = [
            .displayName,
            .aboutMe,
            .pronunciation,
            .pronouns,
            .location,
            .jobTitle,
            .company,
        ]

        #expect(AboutInfoField.all.contains(fields), "`AboutInfoField.all` convenience property must contain the necessary fields")
        #expect(AboutInfoField.all.symmetricDifference(fields).isEmpty, "`AboutInfoField.all` convenience must not have unwanted fields")
    }

    @Test
    func testMultipleSectionsExist() async throws {
        let personalFields: [AboutInfoField] = [
            .displayName,
            .aboutMe,
            .pronunciation,
            .pronouns,
            .location,
        ]
        let professionalFields: [AboutInfoField] = [
            .jobTitle,
            .company,
        ]
        for personalField in personalFields {
            for professionalField in professionalFields {
                let mergedFields = personalField.union(professionalField)
                #expect(
                    mergedFields.hasMultipleCategories == true,
                    "Different combinations of `personal` and `professional` fields mean that there are multiple categories in this set. So we expect `hasMultipleCategories` to be true."
                )
            }
        }
    }

    @Test
    func testMultipleSectionsDontExist() async throws {
        #expect(
            AboutInfoField.personalFields.hasMultipleCategories == false,
            "`personalFields` convenience property corresponds to a single category. So we expect `hasMultipleCategories` to be false"
        )
        #expect(
            AboutInfoField.professionalFields.hasMultipleCategories == false,
            "`professionalFields` convenience property corresponds to a single category. So we expect `hasMultipleCategories` to be false"
        )
    }
}
