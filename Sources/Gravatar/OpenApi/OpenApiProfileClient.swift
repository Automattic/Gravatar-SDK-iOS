import Foundation
import OpenAPIRuntime
import HTTPTypes

//NOTE: This will become our ProfileService
extension Client: ProfileFetching {
    func fetch(with profileID: ProfileIdentifier) async throws -> UserProfile {
        do {
            let resposne = try await getProfileById(Operations.getProfileById.Input(path: Operations.getProfileById.Input.Path(profileIdentifier: profileID.id)))
            switch resposne {
            case .ok(let profile):
                break // return try profile.body.json -> Will return the actual Profile. Needed to map it into our UserProfile.
            case .notFound(_):
                break
            case .tooManyRequests(_):
                break
            case .internalServerError(_):
                break
            case .undocumented(statusCode: let statusCode, _):
                break
            }
        } catch {
            // Map into ProfileService errors.
        }
        fatalError("Not implemented") // Just to make the project build
    }
}
