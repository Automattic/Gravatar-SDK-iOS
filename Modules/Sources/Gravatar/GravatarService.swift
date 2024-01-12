import Foundation
import UIKit

public enum GravatarServiceError: Int, Error {
    case invalidAccountInfo
}

extension GravatarServiceError: CustomDebugStringConvertible {
    public var debugDescription: String {
        switch self {
        case .invalidAccountInfo:
            return "Invalid account info"
        }
    }
}

/// This Service exposes all of the valid operations we can execute, to interact with the Gravatar Service.
///
open class GravatarService {

    public init() {}

    /// This method fetches the Gravatar profile for the specified email address.
    ///
    /// - Parameters:
    ///     - email: The email address of the gravatar profile to fetch.
    ///     - completion: A completion block.
    ///
    open func fetchProfile(email: String, onCompletion: @escaping ((_ result: GravatarProfileFetchResult) -> Void)) {
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
            onCompletion(.success(profile))

        }, failure: { error in
            onCompletion(.failure(.invalidAccountInfo))
        })
    }


    /// This method hits the Gravatar Endpoint, and uploads a new image, to be used as profile.
    ///
    /// - Parameters:
    ///     - image: The new Gravatar Image, to be uploaded
    ///     - accountEmail: Email address associated with the image
    ///     - accountToken: OAuth token
    ///     - completion: An optional closure to be executed on completion.
    ///
    open func uploadImage(_ image: UIImage, accountEmail: String, accountToken: String, completion: ((_ error: NSError?) -> ())? = nil) {
        guard !accountEmail.isEmpty,
              !accountToken.isEmpty else {
            completion?(GravatarServiceError.invalidAccountInfo as NSError)
            return
        }

        let remote = gravatarServiceRemote()
        remote.uploadImage(
            image,
            accountEmail: accountEmail,
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
