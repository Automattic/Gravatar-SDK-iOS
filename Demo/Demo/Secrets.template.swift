// Template for the demo app's secrets. Do not edit — the build phase copies this
// into DerivedData (or, with real credentials, materializes it there).
//
// Internal contributors: run `bundle exec fastlane configure_secrets` to decrypt
// the real credentials, which land outside the repo under ~/.a8c-secrets.
// External contributors: the first build copies this file to the gitignored
// `Demo/Demo/Secrets.external-contributors.swift`; put your own credentials from
// https://gravatar.com/developers/applications there. Otherwise the demo builds
// with the empty defaults below.

struct Secrets {
    static let apiKey: String? = nil
    static let clientID: String = ""
    static let redirectURI: String = ""
}
