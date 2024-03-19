import Foundation

/// Represents the task of a data downloading process, which can be cancelled while it's running.
///
/// We offer a default implementation of `CancellableDataTask` for `URLSessionTask` and `Task`.
public protocol CancellableDataTask {
    /// Cancells a running task.
    func cancel()
}

extension URLSessionTask: CancellableDataTask {}

extension Task: CancellableDataTask {}
