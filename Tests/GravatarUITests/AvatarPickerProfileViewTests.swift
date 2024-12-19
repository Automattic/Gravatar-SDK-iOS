@testable import GravatarUI
import SnapshotTesting
import SwiftUI
import XCTest

final class AvatarPickerProfileViewTests: XCTestCase {
    override func invokeTest() {
        withSnapshotTesting(record: .failed) {
            super.invokeTest()
        }
    }

    @MainActor
    func testAvatarPickerProfileView() throws {
        let testView =
            VStack(alignment: .leading, content: {
                AvatarPickerProfileView(
                    avatarURL: .constant(nil),
                    model: .constant(
                        .init(
                            displayName: "Shelly Kimbrough",
                            location: "San Antonio, TX",
                            profileURL: URL(string: "https://gravatar.com")
                        )
                    ),
                    isLoading: .constant(false)
                )
                .frame(maxWidth: .infinity, alignment: .leading)
            })
            .frame(minWidth: 300)

        assertSnapshots(
            of: testView,
            as: [
                .testStrategy(userInterfaceStyle: .light, layout: .sizeThatFits),
                .testStrategy(userInterfaceStyle: .dark, layout: .sizeThatFits),
            ]
        )
    }
}
