class TableViewController: UITableViewController {

// ... All code from before ...

    func addProfile(with email: String) {
        guard !email.isEmpty else { return }

        var config = ProfileViewConfiguration.summary()
        config.isLoading = true
        models[email] = config

        snapshot.appendItems([email])
        dataSource.apply(snapshot)

        Task {
            do {
                try await fetchProfile(with: email)
            } catch {
                // Do proper error handling
                print(error)
            }
        }
    }

    func fetchProfile(with email: String) async throws {
        let service = ProfileService()
        let profile = try await service.fetch(with: .email(email))
        models[email] = .summary(model: profile)

        snapshot.reloadItems([email])
        await dataSource.apply(snapshot)
    }
}
