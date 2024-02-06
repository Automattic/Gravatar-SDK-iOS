import Foundation

struct FetchProfileResponse: Decodable {
    let entry: [ProfileRemote]
}

struct ProfileRemote: Decodable {
    let hash: String
    let requestHash: String
    let profileUrl: String
    let preferredUsername: String
    let thumbnailUrl: String
    let displayName: String
    let name: ProfileName?
}

public struct ProfileName: Decodable {
    let givenName: String
    let familyName: String
    let formatted: String
}
