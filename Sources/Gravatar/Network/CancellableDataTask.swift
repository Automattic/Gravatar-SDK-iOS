import Foundation

/// Allows you to cancel the data task.
public protocol CancellableDataTask {
    func cancel()
}

extension URLSessionTask: CancellableDataTask {}

extension Task: CancellableDataTask {}
