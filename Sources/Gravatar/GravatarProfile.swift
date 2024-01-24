//
//  GravatarProfile.swift
//
//
//  Created by Andrew Montgomery on 1/10/24.
//

public enum GravatarProfileFetchResult: Equatable {
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
