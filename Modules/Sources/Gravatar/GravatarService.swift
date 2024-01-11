import Foundation
import UIKit

public enum GravatarServiceError: Int, Error {
    case invalidAccountInfo
}

/// This Service exposes all of the valid operations we can execute, to interact with the Gravatar Service.
///
open class GravatarService {

    /// This method fetches the Gravatar profile for the specified email address.
    ///
    /// - Parameters:
    ///     - email: The email address of the gravatar profile to fetch.
    ///     - completion: A completion block.
    ///
    open func fetchProfile(email: String, onCompletion: @escaping ((_ profile: GravatarProfile?) -> Void)) {
        let remote = gravatarServiceRemote()
        remote.fetchProfile(email, success: { remoteProfile in
            var profile = GravatarProfile()
            profile.profileID = remoteProfile.profileID
            profile.hash = remoteProfile.hash
            profile.requestHash = remoteProfile.requestHash
            profile.profileUrl = remoteProfile.profileUrl
            profile.preferredUsername = remoteProfile.preferredUsername
            profile.thumbnailUrl = remoteProfile.thumbnailUrl
            profile.name = remoteProfile.name
            profile.displayName = remoteProfile.displayName
            onCompletion(profile)

        }, failure: { error in
            onCompletion(nil)
        })
    }


    /// This method hits the Gravatar Endpoint, and uploads a new image, to be used as profile.
    ///
    /// - Parameters:
    ///     - image: The new Gravatar Image, to be uploaded
    ///     - accountEmail: The email address associated with the Gravatar image
    ///     - accountToken: A Gravatar OAuth token
    ///     - completion: An optional closure to be executed on completion.
    ///
    open func uploadImage(_ image: UIImage, accountEmail: String, accountToken: String, completion: ((_ error: NSError?) -> ())? = nil) {
        guard
            !accountToken.isEmpty,
            !accountEmail.isEmpty else {
                completion?(GravatarServiceError.invalidAccountInfo as NSError)
                return
        }

        let email = accountEmail.trimmingCharacters(in: CharacterSet.whitespaces).lowercased()

        let remote = gravatarServiceRemote()
        remote.uploadImage(
            image,
            accountEmail: email,
            accountToken: accountToken,
            completion: completion
        )
    }

    /// Overridden by tests for mocking.
    ///
    func gravatarServiceRemote() -> GravatarServiceRemote {
        return GravatarServiceRemote()
    }
}
