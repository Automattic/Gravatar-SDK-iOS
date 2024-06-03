class TableViewController: UITableViewController {

// ... All code from before ...

    func fetchProfile(with email: String) async throws {
        // Create a profile service and fetch a profile using the given email.
        let service = ProfileService()
        let profile = try await service.fetch(with: .email(email))

        // Create a Summary ProfileViewConfiguration to display the profile obtained,
        // and store it to be retreived later on.
        models[email] = .summary(model: profile)

        // Reload the cell for the given email.
        // This will update the cell from the loading to the displaying info state.
        snapshot.reloadItems([email])
        await dataSource.apply(snapshot)
    }
}
