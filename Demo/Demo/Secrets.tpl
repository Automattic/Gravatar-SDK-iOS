// Secrets used in the demo app, materialized into DerivedData at build time.
//
// Internal contributors: run `bundle exec fastlane configure_secrets` to decrypt
// the real credentials, which land outside the repo under ~/.a8c-secrets.
// Without them the demo builds with the empty defaults below. To test OAuth with
// your own https://gravatar.com/developers/applications credentials, fill these
// in — but don't commit that change.

struct Secrets {
    static let apiKey: String? = nil
    static let clientID: String = ""
    static let redirectURI: String = ""
}
