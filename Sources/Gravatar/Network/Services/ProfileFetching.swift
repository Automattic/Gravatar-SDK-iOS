protocol ProfileFetching {
    /// Fetches a Gravatar user's profile information, and delivers the user profile asynchronously.
    /// - Parameter email: The user account email.
    /// - Returns: An asynchronously-delivered user profile.
    func fetch(withEmail email: String) async throws -> UserProfile

    /// Fetches a Gravatar user's profile information, and delivers the user profile asynchronously.
    /// - Parameter hash: The user's email sha256 hash which corresponds to their account. For more info, check [the gravatar
    /// documentation](https://docs.gravatar.com/general/hash/).
    /// - Returns: An asynchronously-delivered user profile.
    func fetch(withHash hash: String) async throws -> UserProfile

    /// Fetches a Gravatar user's profile information, and delivers the user profile asynchronously.
    /// - Parameter userName: The user's account user name.
    /// - Returns: An asynchronously-delivered user profile.
    func fetch(withUserName userName: String) async throws -> UserProfile
}
