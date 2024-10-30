import SwiftUI

private struct OAuthSessionKey: EnvironmentKey {
    static let defaultValue: OAuthSession = .shared
}

extension EnvironmentValues {
    public var oauthSession: OAuthSession {
        get { self[OAuthSessionKey.self] }
        set { self[OAuthSessionKey.self] = newValue }
    }
}
