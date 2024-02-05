//
//  GravatarProfile.swift
//
//
//  Created by Andrew Montgomery on 1/10/24.
//

public enum GravatarProfileFetchResult {
    case success(GravatarProfile)
    case failure(GravatarServiceError)
}

public struct GravatarProfile: Equatable {

    public internal(set) var profileID = ""
    public internal(set) var hash = ""
    public internal(set) var requestHash = ""
    public internal(set) var profileUrl = ""
    public internal(set) var preferredUsername = ""
    public internal(set) var thumbnailUrl = ""
    public internal(set) var name = ""
    public internal(set) var displayName = ""

}

extension GravatarProfile {
    init(with remote: ProfileRemote) {
        hash = remote.hash
        requestHash = remote.requestHash
        profileUrl = remote.profileUrl
        preferredUsername = remote.preferredUsername
        thumbnailUrl = remote.thumbnailUrl
        name = remote.name?.formatted ?? ""
        displayName = remote.displayName
    }
}
