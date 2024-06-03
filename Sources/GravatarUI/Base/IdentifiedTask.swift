import Foundation

struct IdentifiedTask<ID: Equatable, T: Sendable> {
    let id: ID
    let task: Task<T, Never>

    init(id: ID, operation: @escaping @Sendable () async -> T) {
        self.id = id
        self.task = Task(operation: operation)
    }
}
