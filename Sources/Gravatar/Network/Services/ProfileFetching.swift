protocol ProfileFetching {
    /// Fetches a Gravatar user's profile information, and delivers the user profile asynchronously.
    /// - Parameter profileID: a ProfileIdentifier
    /// - Returns: An asynchronously-delivered user profile.
    func fetch(with profileID: ProfileIdentifier) async throws -> Profile
}
