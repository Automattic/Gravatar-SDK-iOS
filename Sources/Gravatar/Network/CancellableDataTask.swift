import Foundation

/// Represents the task of a data downloading process, which can be cancelled while it's running.
///
/// We offer a default implementation of `CancellableDataTask` for `Task`.
public protocol CancellableDataTask {
    /// Cancells a running task.
    func cancel()

    /// Was the task cancelled?
    var isCancelled: Bool { get }
}

extension Task: CancellableDataTask {}
