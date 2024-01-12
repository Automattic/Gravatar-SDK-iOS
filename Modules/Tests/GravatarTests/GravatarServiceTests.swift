import Foundation
import Gravatar
import XCTest

/// GravatarService Unit Tests
///
class GravatarServiceTests: XCTestCase {
    struct MessageData {
        var capturedToken: String? = nil
        var capturedEmail: String? = nil
        var capturedHash: String? = nil
        var capturedImageUpload: UIImage? = nil
        var capturedImageUploadCompletion: ((NSError?) -> ())? = nil
    }

    class GravatarServiceRemoteMock: GravatarServiceRemote {
        var capturedAccountTokens: [String?] { messages.map { $0.capturedToken } }
        var capturedAccountEmails: [String?] { messages.map { $0.capturedEmail } }
        var capturedHashes: [String?] { messages.map { $0.capturedHash } }
        var caputuredImageUploads: [UIImage?] { messages.map { $0.capturedImageUpload } }

        var messages = [MessageData]()

        override func uploadImage(_ image: UIImage, accountEmail: String, accountToken: String, completion: ((NSError?) -> ())?) {
            messages.append(
                MessageData(
                    capturedToken: accountToken,
                    capturedEmail: accountEmail,
                    capturedImageUpload: image,
                    capturedImageUploadCompletion: completion
                )
            )
        }

            if let completion = completion {
                completion(nil)
            }
        }

    }

    class GravatarServiceTester: GravatarService {
        var gravatarServiceRemoteMock: GravatarServiceRemoteMock?

        override func gravatarServiceRemote() -> GravatarServiceRemote {
            gravatarServiceRemoteMock = GravatarServiceRemoteMock()
            return gravatarServiceRemoteMock!
        }
    }

    func testUploadImageSanitizesEmailAddressCapitals() {
        let token = "1234"
        let emailAddress = "emAil@wordpress.com"

        let gravatarService = GravatarServiceTester()
        gravatarService.uploadImage(UIImage(), accountEmail: emailAddress, accountToken: token)

        XCTAssertEqual(["email@wordpress.com"], gravatarService.gravatarServiceRemoteMock!.capturedAccountEmails)
    }

    func testUploadImageSanitizesEmailAddressTrimsSpaces() {
        let token = "1234"
        let emailAddress = " email@wordpress.com "

        let gravatarService = GravatarServiceTester()
        gravatarService.uploadImage(UIImage(), accountEmail: emailAddress, accountToken: token)

        XCTAssertEqual(["email@wordpress.com"], gravatarService.gravatarServiceRemoteMock!.capturedAccountEmails)
    }
}
